FROM centos:7

RUN yum -y update \
 && yum -y install curl net-tools sudo wget \
 && yum -y install epel-release \
 && yum clean all

# install nginx
# (Rationale: gunicorn does not serve static files. To avoid an extra deployment interface,
# nginx serves /static/ it within the container)
RUN  yum -y install nginx \
 && yum clean all
RUN mkdir -p /var/log/nginx/ /config/etc/nginx
COPY install/etc/nginx /config/etc/nginx

# install python3.6 (required minimum for this Django app)
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
 && yum -y install python36u python36u-setuptools python36u-devel python36u-pip \
 && ln -sf /usr/bin/python3.6 /usr/bin/python3 \
 && ln -sf /usr/bin/pip3.6 /usr/bin/pip3 \
 && yum clean all

# install application
COPY install/satosa_rpmgr /opt/satosa_rpmgr
RUN mkdir -p /config/etc/satosa_rpmgr
COPY install/satosa_rpmgr/satosa_rpmgr/settings_prod.py.default /config/etc/satosa_rpmgr/settings_prod.py
COPY install/etc/gunicorn /config/etc/gunicorn
COPY install/etc/profile.d/satosa_rpmgr.sh /etc/profile.d/satosa_rpmgr.sh
COPY install/opt/bin /opt/bin
RUN pip3.6 install virtualenv \
 && mkdir -p /opt/venv \
 && virtualenv --python=/usr/bin/python3.6 /opt/venv/satosa_rpmgr \
 && source /opt/venv/satosa_rpmgr/bin/activate \
 && pip install -r /opt/satosa_rpmgr/requirements.txt \
 && chmod +x /opt/bin/*

VOLUME /config \
       /opt/satosa_rpmgr/database \
       /var/log/nginx/
EXPOSE 8080
SHELL ["/bin/bash", "-l", "-c"]