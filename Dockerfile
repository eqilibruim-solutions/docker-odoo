FROM debian:jessie
MAINTAINER Niboo SPRL <info@niboo.be>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python-gevent \
            python-pip \
            python-pyinotify \
            python-renderpm \
            python-support \
            git \
            ssh-client \
            postgresql-client \
            python-babel \
            python-dateutil \
            python-decorator \
            python-docutils \
            python-feedparser \
            python-imaging \
            python-jinja2 \
            python-ldap \
            python-libxslt1 \
            python-lxml \
            python-mako \
            python-mock \
            python-openid \
            python-passlib \
            python-psutil \
            python-psycopg2 \
            python-pychart \
            python-pydot \
            python-pyparsing \
            python-pypdf \
            python-reportlab \
            python-requests \
            python-suds \
            python-tz \
            python-vatnumber \
            python-vobject \
            python-werkzeug \
            python-xlwt \
            python-yaml \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && pip install psycogreen==1.0

# Install Odoo
ENV ODOO_VERSION 9.0
RUN set -x; \
        mkdir -p /opt/local/odoo/odoo \
        && cd /opt/local/odoo/odoo \
        && git init \
        && git remote add origin https://github.com/Odoo/odoo.git \
        && git fetch \
        && git checkout -t origin/${ODOO_VERSION} \
        && ln -s /opt/local/odoo/odoo/openerp-server /usr/bin/openerp-server \
        && ln -s /opt/local/odoo/odoo/openerp-gevent /usr/bin/openerp-gevent \
        && useradd odoo -d /opt/local/odoo -p odoo \
        && chown -R odoo /opt/local/odoo

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
#ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
