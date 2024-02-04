#!/bin/sh

pospid=`cat /var/run/positron.pid`
[ -d "/proc/${pospid}" ] && exit || echo "didn't find running positron"

killall -15 positron
/etc/init.d/S95videosys start

