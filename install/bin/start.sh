#!/bin/bash

scriptsdir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
source $scriptsdir/setenv.sh

$APPHOME/bin/init_database.sh

# start nginx (used to serve static files)
/usr/sbin/nginx -c /opt/etc/nginx/nginx.conf

# start gunicorn
export PYTHONPATH=$APPHOME:/opt/etc/satosa_rpmgr/
source /etc/profile.d/satosa_rpmgr.sh
gunicorn satosa_rpmgr.wsgi:application -c /opt/etc/gunicorn/config.py &

echo 'stay forever'
while true; do sleep 36000; done

echo 'interrupted; exiting shell -> may exit the container'
