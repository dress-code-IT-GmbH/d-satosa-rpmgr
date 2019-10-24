FROM intra/ubi8-py36
# intra/ubi8-py36 is a synonym to registry.access.redhat.com/ubi8/python-36

USER root
RUN yum -y update \
 && yum -y install iputils logrotate net-tools sudo  \
 && yum clean all

# install nginx
# (Rationale: gunicorn does not serve static files. To avoid an extra deployment interface,
# nginx serves /static/ within this container)
RUN  yum -y install nginx \
 && yum clean all
RUN mkdir -p /opt/etc/nginx /var/log/nginx/ /var/run/nginx/  \
 && chown nginx:nginx /var/log/nginx/ /var/run/nginx/
COPY install/etc/nginx /opt/etc/nginx

# install application
ENV APPHOME=/opt/satosa_rpmgr
ENV CONFIGHOME=/opt/etc/satosa_rpmgr
ENV PYTHONPATH=$APPHOME:$CONFIGHOME
COPY install/satosa_rpmgr /opt/satosa_rpmgr
RUN mkdir -p /opt/etc/satosa_rpmgr
COPY install/satosa_rpmgr/satosa_rpmgr/settings_prod.py.default /opt/etc/satosa_rpmgr/settings_prod.py
COPY install/etc/gunicorn /opt/etc/gunicorn
COPY install/etc/profile.d/satosa_rpmgr.sh /etc/profile.d/satosa_rpmgr.sh
COPY install/bin /opt/bin
RUN python -m pip install virtualenv \
 && mkdir -p /opt/venv /var/log/webapp /var/run/webapp $APPHOME/export \
 && virtualenv /opt/venv/satosa_rpmgr \
 && source /opt/venv/satosa_rpmgr/bin/activate \
 && python -m pip install -r $APPHOME/requirements.txt \
 && chmod +x /opt/bin/* /opt/satosa_rpmgr/bin/* \
 && adduser --user-group webapp \
 && chown -R webapp:webapp /var/run/webapp $APPHOME/export

COPY install/etc/logrotate /opt/etc/logrotate

ARG TIMEZONE='Europe/Vienna'
VOLUME /opt/etc \
       /opt/satosa_rpmgr/database \
       /opt/satosa_rpmgr/export \
       /var/log/nginx/
EXPOSE 8080
SHELL ["/bin/bash", "-l", "-c"]