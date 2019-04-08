#!/bin/bash

# show main processes
echo "show container processes (expect gunicorn)"
ps -eaf | head -1
ps -eaf | grep -E 'gunicorn ' |grep -v '00 grep'
ps -eaf | grep -E 'nginx ' |grep -v '00 grep'
