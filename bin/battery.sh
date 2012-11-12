#!/bin/sh
/usr/bin/pmset -g ps | awk '{ if (NR == 2) print "Power:" $2; }' | sed "s/;//g"
