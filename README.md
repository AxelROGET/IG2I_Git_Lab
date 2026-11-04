# TP Git – IG2I
## Utilisation

Prérequis : Docker (Docker Desktop sous Windows/macOS, Docker Engine sous Linux) avec Compose v2.

```bash
docker compose up -d --build --wait      # build + démarrage ; rend la main quand tout est prêt
```

| Service | URL | Identifiants |
|---|---|---|
| Gitea | http://localhost:3000 | `ig2i_dev` / `ig2i_dev` (administrateur) |
| VS Code (navigateur) | http://localhost:8080 | aucun |
| Terminal seul | `docker exec -it linux bash` | – |

## Réinitialiser le TP

```bash
docker compose down -v                   # supprime conteneurs ET volumes
docker compose up -d --wait              # repart de zéro (pas de rebuild nécessaire)
```