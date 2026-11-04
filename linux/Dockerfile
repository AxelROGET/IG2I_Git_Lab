# Machine de développement du TP : Debian (compatible VS Code Server), minimale.
FROM debian:bookworm-slim

# Version de code-server ("" = dernière). Exemple pour figer : --build-arg CODE_SERVER_VERSION=4.96.4
ARG CODE_SERVER_VERSION=""

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TZ=Europe/Paris \
    GIT_MERGE_AUTOEDIT=no

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git openssh-client nano curl wget ca-certificates less procps \
 && rm -rf /var/lib/apt/lists/*

# VS Code dans le navigateur (code-server). Installation "standalone", sans systemd.
RUN curl -fsSL https://code-server.dev/install.sh \
 | sh -s -- --method=standalone --prefix=/usr/local ${CODE_SERVER_VERSION:+--version ${CODE_SERVER_VERSION}}

COPY gitconfig /etc/gitconfig
COPY colleague.sh /usr/local/bin/colleague
RUN chmod +x /usr/local/bin/colleague

RUN useradd -m -u 1000 -s /bin/bash dev \
 && mkdir -p /home/dev/.local/share/code-server/User
COPY settings.json /home/dev/.local/share/code-server/User/settings.json
# Invite de commande avec le nom de la branche courante
RUN printf '%s\n' \
  'source /usr/lib/git-core/git-sh-prompt' \
  "export PS1='\\[\\e[32m\\]\\u@linux\\[\\e[0m\\]:\\[\\e[34m\\]\\w\\[\\e[33m\\]\$(__git_ps1 \" (%s)\")\\[\\e[0m\\]\\\$ '" \
  >> /home/dev/.bashrc \
 && chown -R dev:dev /home/dev

USER dev
WORKDIR /home/dev
EXPOSE 8080
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "--disable-telemetry", "--disable-update-check", "/home/dev"]
