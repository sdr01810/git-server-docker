#!/bin/sh

# Copy all public keys (if any) to the authorized_keys file.
if [ "$(ls -A /git-server/keys/)" ]; then
  cat /git-server/keys/*.pub > /home/git/.ssh/authorized_keys
fi

# Check permissions and fix-up the SGID bit in the repos folder.
# More info: https://github.com/jkarlosb/git-server-docker/issues/1
if [ "$(ls -A /git-server/repos/)" ]; then
  cd /git-server/repos
  chown -R git:git .
  chmod -R ug+rwX .
  find . -type d -exec chmod g+s '{}' +
fi

# Start the ssh server in the foreground, *not* as a daemon
(set -x ; /usr/sbin/sshd -D) ||
echo 1>&2 "The ssh server has failed unexpectedly; exit code: $?"
