FROM alpine:3.6

MAINTAINER Carlos Bernárdez "carlos@z4studios.com"

# "--no-cache" is new in Alpine 3.3 and it avoids the need for
# "--update + rm -rf /var/cache/apk/*" (to remove the cache)
RUN apk add --no-cache \
# openssh=7.5_p1-r1
  openssh \
# git=2.13.0-r0
  git

# Generate the server's public/private key pair.
RUN ssh-keygen -A

WORKDIR /git-server

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
  && mkdir /git-server/keys \
  && mkdir /git-server/repos

# Custom commands honored by git-shell can be placed
# in the directory 'git-shell-commands'.
COPY git-shell-commands /home/git/git-shell-commands

# Uncomment the following line to allow (restricted) interactive login as git:
#RUN rm /home/git/git-shell-commands/no-interactive-login

# Initialize git home directory.
RUN cd /home/git && mkdir -p .ssh && \
	cp /dev/null .ssh/authorized_keys && \
	chmod -R 600 .ssh && chmod 700 .ssh && \
	(chmod +rx git-shell-commands/* || :) && \
	chown -R git:git .

# The sshd_config file has been edited as follows:
# 1. enable authorization via public/private key pairs
# 2. disable authorization via password
COPY sshd_config /etc/ssh/sshd_config

# The start script handles first-time setup,
# and launches the SSH server.
COPY start.sh start.sh

# SSH port:
EXPOSE 22

VOLUME ["/git-server/keys", "/git-server/repos"]

CMD ["sh", "start.sh"]
