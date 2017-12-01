#!/bin/sh
/usr/bin/pmset -g ps | awk '{ if (NR == 2) print $3":" $4; }' | sed "s/;//g"
