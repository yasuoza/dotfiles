#!/bin/zsh -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [[ ! $(getent group $GROUP_ID) ]]; then
  groupadd -g $GROUP_ID $USER
fi

if [[ ! $(getent passwd $USER) ]]; then
  useradd -s /bin/zsh -u $USER_ID -g $GROUP_ID $USER
else
  usermod -u $USER_ID $USER
fi

# Revert permission
sudo chmod u-s /usr/sbin/useradd
sudo chmod u-s /usr/sbin/groupadd
sudo chmod u-s /usr/sbin/usermod
sudo chmod u-s /usr/sbin/groupmod

exec $@
