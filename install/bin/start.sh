#!/bin/bash

scriptsdir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
source $scriptsdir/setenv.sh


main() {
    start_reverse_proxy
    start_appserver
    keep_running
    trap propagate_signals SIGTERM
}


start_appserver() {
    $APPHOME/bin/init_database.sh
    source /etc/profile.d/satosa_rpmgr.sh
    gunicorn satosa_rpmgr.wsgi:application -c /opt/etc/gunicorn/config.py --pid /var/run/webapp/gunicorn.pid &
}


start_reverse_proxy() {
    # start nginx (used to serve static files)
    /usr/sbin/nginx -c /opt/etc/nginx/nginx.conf
}


propagate_signals() {
    kill -s SIGTERM $(cat /var/run/webapp/gunicorn.pid)
    kill -s SIGQUIT $(cat /var/run/nginx/nginx.pid)
}


keep_running() {
    echo 'wait for SIGINT/SIGKILL'
    while true; do sleep 36000; done
    echo 'interrupted; exiting shell -> may exit the container'
}


main $@
