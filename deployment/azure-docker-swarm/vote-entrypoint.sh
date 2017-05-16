#!/bin/bash

# Update Azure vote config file
sed -i "s/<user>/$1/g" /opt/vote-app/config_file.cfg
sed -i "s/<password>/$2/g" /opt/vote-app/config_file.cfg
sed -i "s/<ip>/$3/g" /opt/vote-app/config_file.cfg

# Initial application start
supervisorctl reread
supervisorctl update
supervisorctl start azurevote

# Reload NGINX
nginx -s reload