#!/bin/zsh -e

# run command as developer user
# docker run -it --rm dotfiles
# uid=1000(developer) gid=1000(developer) groups=1000(developer)

# see that it is mapping
# docker run -it --rm -v $PWD:/home/developer/works -w /home/developer/works dotfiles
# uid=1000(developer) gid=1001(developer) groups=1001(developer)

# use another directory
# docker run -it --rm -v $PWD:/data -e MAP_NODE_UID=/data dotfiles
# uid=1000(developer) gid=1001(developer) groups=1001(developer)

# disable mapping
# docker run -it --rm -v $PWD:/home/developer/works -w /home/developer/works -e MAP_NODE_UID=no dotfiles
# uid=1000(developer) gid=1000(developer) groups=1000(developer)

uid=$(id -u)
gid=$(id -g)

if [ "$MAP_NODE_UID" != "no" ]; then
    if [ ! -d "$MAP_NODE_UID" ]; then
        MAP_NODE_UID=$PWD
    fi

    uid=$(stat -c '%u' "$MAP_NODE_UID")
    gid=$(stat -c '%g' "$MAP_NODE_UID")

    usermod -u $uid $USER 2> /dev/null && {
        groupmod -g $gid $USER 2> /dev/null || usermod -a -G $gid $USER
    }
fi

exec /usr/sbin/gosu $USER "$@"
