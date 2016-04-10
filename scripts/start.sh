#!/bin/bash

# Define some constants that are reused in this script
PATH_NGINX=/usr/share/nginx
PATH_HTML=$PATH_NGINX/html/

# Disable Strict Host checking for non interactive git clones
mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Set up git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

# Install extras
if [ ! -z "$DEBS" ]; then
 apt-get update
 apt-get install -y $DEBS
fi

# Pull down code from git for our site!
if [ ! -z "$GIT_REPO" ]; then
  rm /usr/share/nginx/html/*
  if [ ! -z "$GIT_BRANCH" ]; then
    git clone -b $GIT_BRANCH $GIT_REPO $PATH_HTML
  else
    git clone $GIT_REPO $PATH_HTML
  fi
  chown -Rf nginx.nginx $PATH_NGINX/*
fi

# Display PHP errors or not
if [[ "$ERRORS" != "1" ]] ; then
  sed -i -e "s/error_reporting =.*=/error_reporting = E_ALL/g" /etc/php5/fpm/php.ini
  sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php5/fpm/php.ini
fi

# Tweak nginx to match workers to CPUs
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Very dirty hack to replace variables in code with ENVIRONMENT values
if [[ "$TEMPLATE_NGINX_HTML" == "1" ]] ; then
  for i in $(env)
  do
    variable=$(echo "$i" | cut -d'=' -f1)
    value=$(echo "$i" | cut -d'=' -f2)
    if [[ "$variable" != '%s' ]] ; then
      replace='\$\$_'${variable}'_\$\$'
      find /usr/share/nginx/html -type f -exec sed -i -e 's/'${replace}'/'${value}'/g' {} \;
    fi
  done
fi

# Set user and group of website files (needed when mounting from a volume)
if [ -z "$SET_USER" ]; then
  # In production it is recommended to:  -e SET_USER=www-data
  chown -Rf $SET_USER.www-data $PATH_HTML
else
  # In development you keep your user and we set the group only
  chgrp -Rf www-data $PATH_HTML
fi

# Start supervisord and the services configured therein
/usr/bin/supervisord -n -c /etc/supervisord.conf
