FROM alpine:3.4

MAINTAINER Carlos Bernárdez "carlos@z4studios.com"

# "--no-cache" is new in Alpine 3.3 and it avoids the need for
# "--update + rm -rf /var/cache/apk/*" (to remove the cache)
RUN apk add --no-cache \
# openssh=7.2_p2-r1
  openssh \
# git=2.8.3-r0
  git

# Generate the server's public/private key pair.
RUN ssh-keygen -A

# SSH autorun
# RUN rc-update add sshd

WORKDIR /git-server/

# Notable adduser flags:
# -D avoids password generation
# -s changes user's shell
#
# '/usr/bin/git-shell' is a restricted login shell.
# It does all the heavy lifting when it comes to
# providing remote git service. For further info:
# https://git-scm.com/docs/git-shell
RUN adduser -D -s /usr/bin/git-shell git \
  && echo git:12345 | chpasswd \
  && mkdir /home/git/.ssh \
  && mkdir /git-server/keys \
  && mkdir /git-server/repos

# Custom commands honored by git-shell can be placed
# in the directory 'git-shell-commands'.
COPY git-shell-commands /home/git/git-shell-commands

# The sshd_config file has been edited as follows:
# 1. enable authorization via public/private key pairs
# 2. disable authorization via password
COPY sshd_config /etc/ssh/sshd_config

# The start script handles first-time setup,
# and launches the ssh server.
COPY start.sh start.sh

EXPOSE 22

CMD ["sh", "start.sh"]
