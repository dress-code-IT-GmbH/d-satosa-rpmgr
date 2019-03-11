#!/bin/bash

export PYTHONPATH=/opt/satosa_rpmgr
export DJANGO_SETTINGS_MODULE=satosa_rpmgr.settings

# start gunicorn
source /etc/profile.d/pvzdweb.sh
gunicorn rpmgr.wsgi:application -c /config/etc/gunicorn/config.py &

echo 'stay forever'
while true; do sleep 36000; done

echo 'interrupted; exiting shell -> may exit the container'
