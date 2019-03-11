#!/bin/bash

export PYTHONPATH=/opt/satosa_rpmgr
export DJANGO_SETTINGS_MODULE=satosa_rpmgr.settings

# start nginx (used to serve static files)
/usr/sbin/nginx -c /config/etc/nginx/nginx.conf

# start gunicorn
source /etc/profile.d/satosa_rpmgr.sh
gunicorn satosa_rpmgr.wsgi:application -c /config/etc/gunicorn/config.py &

echo 'stay forever'
while true; do sleep 36000; done

echo 'interrupted; exiting shell -> may exit the container'
