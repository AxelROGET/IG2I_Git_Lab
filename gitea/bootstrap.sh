#!/bin/bash
# Bootstrap du TP : s'exécute dans le conteneur Gitea, une seule fois (marqueur /data/.lab_ready).
#   1. attend que Gitea réponde
#   2. crée l'utilisateur admin ig2i_dev / ig2i_dev
#   3. crée le dépôt ig2i_dev/pinf et y pousse tout l'historique (build_repo.sh)
#   4. protège main et release/1.0 (push direct interdit)
# Les logs sont dans `docker logs gitea_server` et /data/lab-bootstrap.log
set -uo pipefail
exec > >(tee -a /data/lab-bootstrap.log) 2>&1

MARK=/data/.lab_ready
ADMIN=ig2i_dev
PASS=ig2i_dev
EMAIL=ig2i_dev@ig2i.fr
REPO=pinf
API=http://localhost:3000/api/v1
export HOME=/tmp/lab-home; mkdir -p "$HOME"
log() { echo "[lab-bootstrap] $*"; }
http() { curl -s -o /tmp/lab-resp -w '%{http_code}' -u "$ADMIN:$PASS" -H 'Content-Type: application/json' "$@"; }

if [ -f "$MARK" ]; then log "déjà initialisé, rien à faire."; exit 0; fi

log "attente de Gitea..."
for i in $(seq 1 180); do
  curl -fsS "http://localhost:3000/api/healthz" >/dev/null 2>&1 && break
  sleep 2
done
curl -fsS "http://localhost:3000/api/healthz" >/dev/null 2>&1 || { log "ERREUR : Gitea ne répond pas."; exit 1; }

# --- 2. utilisateur -----------------------------------------------------------
if [ "$(http "$API/user")" != "200" ]; then
  log "création de l'utilisateur $ADMIN"
  HOME=/data/git su-exec git gitea admin user create --admin --username "$ADMIN" --password "$PASS" \
      --email "$EMAIL" --must-change-password=false || log "(la commande a échoué, on vérifie ci-dessous)"
fi
[ "$(http "$API/user")" = "200" ] || { log "ERREUR : impossible de s'authentifier avec $ADMIN."; exit 1; }

# --- 3. dépôt + historique ----------------------------------------------------
code="$(http "$API/repos/$ADMIN/$REPO")"
if [ "$code" != "200" ]; then
  log "création du dépôt $ADMIN/$REPO"
  code="$(http -X POST "$API/user/repos" -d "{\"name\":\"$REPO\",\"description\":\"Projet PINF : API de transactions bancaires\",\"private\":false,\"default_branch\":\"main\",\"auto_init\":false}")"
  [ "$code" = "201" ] || { log "ERREUR création dépôt (HTTP $code) : $(cat /tmp/lab-resp)"; exit 1; }
fi

if ! git ls-remote --heads "http://$ADMIN:$PASS@localhost:3000/$ADMIN/$REPO.git" 2>/dev/null | grep -q refs/heads/main; then
  log "construction et push de l'historique"
  /opt/seed/build_repo.sh /tmp/pinf-seed >/dev/null 2>&1 || { log "ERREUR build_repo.sh"; exit 1; }
  git -C /tmp/pinf-seed -c credential.helper= push -q --all "http://$ADMIN:$PASS@localhost:3000/$ADMIN/$REPO.git" \
    || { log "ERREUR : push initial"; exit 1; }
  rm -rf /tmp/pinf-seed
fi

# --- 4. protections de branches -----------------------------------------------
for b in main release/1.0; do
  code="$(http -X POST "$API/repos/$ADMIN/$REPO/branch_protections" \
     -d "{\"rule_name\":\"$b\",\"branch_name\":\"$b\",\"enable_push\":false,\"enable_push_whitelist\":false,\"enable_merge_whitelist\":false,\"required_approvals\":0}")"
  case "$code" in 201) log "branche $b protégée";; 403|409|422) log "protection $b déjà présente (HTTP $code)";;
    *) log "ERREUR protection $b (HTTP $code) : $(cat /tmp/lab-resp)"; exit 1;; esac
done

touch "$MARK"
log "TP prêt : http://localhost:3000  ($ADMIN / $PASS)"
