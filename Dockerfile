FROM centos:7

RUN yum -y update \
 && yum -y install net-tools sudo wget \
 && yum -y install epel-release \
 && yum -y install nginx \
 && yum clean all

# install python3.6 (required minimum for this Django app)
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
 && yum -y install python36u python36u-setuptools python36u-devel python36u-pip \
 && ln -sf /usr/bin/python3.6 /usr/bin/python3 \
 && ln -sf /usr/bin/pip3.6 /usr/bin/pip3 \
 && yum clean all

# install application
COPY install/satosa_rpmgr /opt/satosa_rpmgr
RUN pip3.6 install virtualenv \
 && mkdir -p /opt/venv \
 && virtualenv --python=/usr/bin/python3.6 /opt/venv/satosa_rpmgr \
 && source /opt/venv/satosa_rpmgr/bin/activate \
 && pip install -r /opt/satosa_rpmgr/requirements.txt
COPY install/opt/bin/* /opt/bin/
COPY install/etc/profile.d/satosa_rpmgr.sh /etc/profile.d/satosa_rpmgr.sh
RUN chmod +x /opt/bin/*
VOLUME /opt/satosa_rpmgr/database

# persist deployment-specific configuration
RUN mkdir -p /config/etc/
COPY install/etc /config/etc
COPY install/satosa_rpmgr/static_root /config/satosa_rpmgr/static_root

# nginx log files
RUN mkdir -p /var/log/nginx/
VOLUME /var/log/nginx/

EXPOSE 8080
SHELL ["/bin/bash", "-l", "-c"]