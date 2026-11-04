#!/bin/bash
# Lance le bootstrap du TP en tâche de fond, puis démarre Gitea normalement.
/usr/local/bin/lab-bootstrap.sh &
exec /usr/bin/entrypoint "$@"
