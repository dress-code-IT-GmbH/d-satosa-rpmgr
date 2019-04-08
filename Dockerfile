FROM centos:7

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install curl logrotate net-tools sudo wget \
 && yum clean all

# install nginx
# (Rationale: gunicorn does not serve static files. To avoid an extra deployment interface,
# nginx serves /static/ it within this container)
RUN  yum -y install nginx \
 && yum clean all
RUN mkdir -p /opt/etc/nginx /var/log/nginx/ /var/run/nginx/  \
 && chown nginx:nginx /var/log/nginx/ /var/run/nginx/
COPY install/etc/nginx /opt/etc/nginx

# install python3.6 (required minimum for this Django app)
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
 && yum -y install python36u python36u-setuptools python36u-devel python36u-pip \
 && ln -sf /usr/bin/python3.6 /usr/bin/python3 \
 && ln -sf /usr/bin/pip3.6 /usr/bin/pip3 \
 && yum clean all

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
RUN pip3.6 install virtualenv \
 && mkdir -p /opt/venv /var/log/webapp /var/run/webapp \
 && virtualenv --python=/usr/bin/python3.6 /opt/venv/satosa_rpmgr \
 && source /opt/venv/satosa_rpmgr/bin/activate \
 && pip install -r $APPHOME/requirements.txt \
 && chmod +x /opt/bin/* \
 && adduser --user-group webapp \
 && chown -R webapp:webapp /var/run/webapp

COPY install/etc/logrotate /opt/etc/logrotate

ARG TIMEZONE='Europe/Vienna'
VOLUME /opt/etc \
       /opt/satosa_rpmgr/database \
       /var/log/nginx/
EXPOSE 8080
SHELL ["/bin/bash", "-l", "-c"]