#!/bin/bash

export PYTHONPATH=/opt/satosa_rpmgr:/config/etc/satosa_rpmgr/
export DJANGO_SETTINGS_MODULE=settings_prod

source /etc/profile.d/satosa_rpmgr.sh
