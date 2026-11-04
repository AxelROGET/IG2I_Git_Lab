#!/bin/bash
# Construit le dépôt "pinf" avec son historique (auteurs et dates fixes, donc hash identiques à chaque build).
# Usage : build_repo.sh <dossier_cible>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/patches"
DEST="${1:?usage: build_repo.sh <dossier>}"

rm -rf "$DEST" && mkdir -p "$DEST" && cd "$DEST"
git init -q -b main
git config commit.gpgsign false

# who "Nom" email  -> les commits suivants sont créés par cette personne
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2"; }
# am <patch...> : applique des patchs en gardant auteur ET date d'origine
am() { git am -q --committer-date-is-author-date --whitespace=nowarn "$@"; }
# merge_as : merge à date fixe
merge() { GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git merge -q --no-ff "$1" -m "$3"; }

who Sarah sarah@example.fr
am "$P"/01_master/*.patch

# --- develop (Emeline) -----------------------------------------------------------
git switch -q -c develop
who Emeline emeline@example.fr; am "$P"/02_api/01_init-api.patch

# --- feature/db-connection : Léa, Maxime, puis Pierre ---------------------------------
git switch -q -c feature/db-connection
who Léa lea@example.fr;       am "$P"/03_db_connection/01_configuration.patch
who Maxime maxime@example.fr; am "$P"/03_db_connection/02_google_api_key.patch
who Pierre pierre@example.fr; am "$P"/03_db_connection/03_deleting_google_api_key.patch

# --- develop (Sarah) --------------------------------------------------------------
git switch -q develop
who Sarah sarah@example.fr
am "$P"/02_api/02_adding-.gitignore.patch "$P"/02_api/03_POST-api-dev-users.patch

# --- release/1.0 (Axel) --------------------------------------------------------
git switch -q -c release/1.0
who Axel axel@example.fr; am "$P"/04_production/01_Prod-init.patch

# --- fonctionnalités ----------------------------------------------------------
git switch -q develop; git switch -q -c feature/login
who Sarah sarah@example.fr; am "$P"/05_api_login/01_login.patch

git switch -q develop; git switch -q -c feature/create-user
who Emeline emeline@example.fr; am "$P"/06_api_user/01_create-user.patch

git switch -q develop; git switch -q -c feature/transactions
who Sarah sarah@example.fr; am "$P"/07_api_transaction/*.patch

# --- intégration dans develop (Sarah) ---------------------------------------------
git switch -q develop
who Sarah sarah@example.fr
merge feature/login        "2026-02-28T12:30:00+0000" "Merge branch 'feature/login' into develop"
merge feature/create-user  "2026-02-28T12:40:00+0000" "Merge branch 'feature/create-user' into develop"
merge feature/transactions "2026-02-28T16:30:00+0000" "Merge branch 'feature/transactions' into develop"

# --- catégories (Axel), pas encore intégré ------------------------------------
git switch -q -c feature/transaction-category
who Axel axel@example.fr; am "$P"/08_api_transaction_category/01_adding-category-property-to-transactions.patch

# --- nettoyage des branches locales de travail non publiées -------------------
git switch -q main
for b in feature/login feature/create-user feature/transactions; do git branch -q -D "$b"; done
echo "Dépôt construit dans $DEST :"
git branch --format='  %(refname:short)'
