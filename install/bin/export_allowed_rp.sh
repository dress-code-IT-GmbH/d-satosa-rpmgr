#!/bin/bash

set -e
scriptsdir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
source $scriptsdir/setenv.sh

[[ "$APPHOME" ]] || ( echo 'APPHOME not set'; exit 1)
[[ "$DJANGO_SETTINGS_MODULE" ]] || (echo 'DJANGO_SETTINGS_MODULE not set'; exit 1)
[[ "$TARGET_ENTITYID" ]] || ( echo 'TARGET_ENTITYID not set'; exit 1)

python $APPHOME/satosa_rpmgr/export_allowed_rp.py --entityid $TARGET_ENTITYID
