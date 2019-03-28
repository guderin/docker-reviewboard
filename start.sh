#!/bin/bash
DBUSER="${DBUSER:-reviewboard}"
DBPASSWORD="${DBPASSWORD:-reviewboard}"
DBNAME="${DBNAME:-reviewboard}"

# Get these variables either from PGPORT and PGHOST, or from
# linked "pg" container.
DBPORT="${DBPORT:-3306}"
DBHOST="${DBHOST:-127.0.0.1}"

# Get these variable either from MEMCACHED env var, or from
# linked "memcached" container.
MEMCACHED_LINKED_NOTCP="${MEMCACHED_PORT#tcp://}"
MEMCACHED="${MEMCACHED:-$( echo "${MEMCACHED_LINKED_NOTCP:-127.0.0.1}" )}"

DOMAIN="${DOMAIN:localhost}"

if [[ "${SITE_ROOT}" ]]; then
    if [[ "${SITE_ROOT}" != "/" ]]; then
        # Add trailing and leading slashes to SITE_ROOT if it's not there.
        SITE_ROOT="${SITE_ROOT#/}"
        SITE_ROOT="/${SITE_ROOT%/}/"
    fi
else
    SITE_ROOT=/
fi

mkdir -p /var/www/

CONFFILE=/var/www/reviewboard/conf/settings_local.py

if [[ ! -d /var/www/reviewboard ]]; then
    rb-site install --noinput \
        --domain-name="$DOMAIN" \
        --site-root="$SITE_ROOT" \
        --static-url=static/ --media-url=media/ \
        --db-type=mysql \
        --db-name="$DBNAME" \
        --db-host="$DBHOST" \
        --db-user="$DBUSER" \
        --db-pass="$DBPASSWORD" \
        --cache-type=memcached --cache-info="$MEMCACHED" \
        --web-server-type=lighttpd --web-server-port=8080 \
        --admin-user=admin --admin-password=admin --admin-email=admin@example.com \
        /var/www/reviewboard/
fi

/upgrade-site.py /var/www/reviewboard/rb-version /var/www/reviewboard

if [[ "${DEBUG}" ]]; then
    sed -i 's/DEBUG *= *False/DEBUG=True/' "$CONFFILE"
    cat "${CONFFILE}"
fi

export SITE_ROOT

exec uwsgi --ini /uwsgi.ini
