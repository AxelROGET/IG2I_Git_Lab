# Gitea 1.21 + auto-configuration au premier démarrage (utilisateur, dépôt, protections).
FROM gitea/gitea:1.21

COPY seed/ /opt/seed/
COPY bootstrap.sh /usr/local/bin/lab-bootstrap.sh
COPY lab-entrypoint.sh /usr/local/bin/lab-entrypoint.sh
RUN chmod +x /usr/local/bin/lab-bootstrap.sh /usr/local/bin/lab-entrypoint.sh /opt/seed/build_repo.sh

# On réutilise l'entrypoint d'origine (/usr/bin/entrypoint) après avoir lancé le bootstrap en arrière-plan.
ENTRYPOINT ["/usr/local/bin/lab-entrypoint.sh"]
CMD ["/bin/s6-svscan", "/etc/s6"]
