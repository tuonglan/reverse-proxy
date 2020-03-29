ARG CERTBOT_VERSION=latest

FROM ubuntu:bionic as builder

# Install nginx
RUN apt update && apt install -y gnupg2
COPY nginx/nginx_signing.key /opt/nginx/nginx_signing.key
COPY nginx/nginx.list /etc/apt/sources.list.d/nginx.list
RUN apt-key add /opt/nginx/nginx_signing.key \
    && apt update \
    && apt install -y nginx

# Install crontab
RUN apt-get install cron

# Bootstrap the certbot
# Install 1.3.0 for bootstrapping necessary libraries first (saving building time)
COPY certbot/certbot-auto_1.3.0 /opt/certbot/certbot-auto_1.3.0
RUN /opt/certbot/certbot-auto_1.3.0 --install-only -n

# Upgrade to latest version
COPY certbot/certbot-auto /opt/certbot/certbot-auto
RUN /opt/certbot/certbot-auto --install-only -n

# Set crontab for certbot renew
COPY certbot/crontab_certbot /etc/cron.d/certbot

# Setup nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf

FROM builder
COPY run-proxy.sh /opt/reverse-proxy/
WORKDIR /opt/reverse-proxy/
ENTRYPOINT ["/bin/bash", "./run-proxy.sh"]
