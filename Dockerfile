FROM centos:7

RUN yum -y update \
 && yum -y install net-tools sudo wget \
 && yum -y install epel-release \
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
RUN chmod +x /scripts/*
VOLUME /opt/satosa_rpmgr/database

EXPOSE 8080


# persist deployment-specific configuration
RUN mkdir -p /config/etc/gunicorn
COPY install/etc /config/etc
COPY install/PVZDweb/static_root /config/satosa_rpmgr/static/static
VOLUME /config

SHELL ["/bin/bash", "-l", "-c"]