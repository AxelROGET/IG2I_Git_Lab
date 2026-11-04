#!/bin/bash
# Simule un collègue (Dave) qui pousse un commit sur le serveur pendant que vous travaillez.
# Usage : colleague [branche]      (par défaut : develop)
set -euo pipefail
BRANCH="${1:-develop}"
URL="${LAB_REMOTE_URL:-http://ig2i_dev:ig2i_dev@gitea:3000/ig2i_dev/pinf.git}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone -q --branch "$BRANCH" --single-branch "$URL" "$TMP/pinf"
cd "$TMP/pinf"
git config user.name  "Dave"
git config user.email "dave@example.fr"
git config commit.gpgsign false

echo "- $(date '+%Y-%m-%d %H:%M') : mise à jour de la documentation (Dave)" >> CHANGELOG.md
git add CHANGELOG.md
git commit -q -m "Update changelog"
git push -q origin "$BRANCH"

echo "Dave vient de pousser un commit sur origin/$BRANCH (vous ne l'avez pas encore)."
