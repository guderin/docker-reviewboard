FROM ubuntu:18.04
MAINTAINER igor.katson@gmail.com

ARG RB_VERSION=3.0.14
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
        build-essential python-dev libffi-dev libssl-dev patch vim telnet net-tools curl\
        python-pip python-setuptools python-wheel python-virtualenv

RUN curl http://uwsgi.it/install | bash -s default /usr/bin/uwsgi
RUN apt-get install --no-install-recommends -y \        
        uwsgi-plugin-python \
        postgresql-client \
        python-psycopg2 python-ldap \
        libmysqlclient-dev \
        git-core mercurial subversion python-svn && \
        rm -rf /var/lib/apt/lists/* 

RUN set -ex; \
    if [ "${RB_VERSION}" ]; then RB_VERSION="==${RB_VERSION}"; fi; \
    python -m virtualenv --system-site-packages /opt/venv; \
    . /opt/venv/bin/activate; \
    pip install "ReviewBoard${RB_VERSION}" 'django-storages<1.3' semver mysqlclient uwsgitop; \
    rm -rf /root/.cache

ENV PATH="/opt/venv/bin:${PATH}"

ADD start.sh /start.sh
ADD uwsgi.ini /uwsgi.ini
ADD shell.sh /shell.sh
ADD upgrade-site.py /upgrade-site.py

RUN chmod +x /start.sh /shell.sh /upgrade-site.py

VOLUME /var/www/

EXPOSE 8080

CMD /start.sh
