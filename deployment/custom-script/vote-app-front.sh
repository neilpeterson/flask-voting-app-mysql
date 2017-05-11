#!/bin/bash

# Install software
sudo apt-get update -y
sudo apt-get install nginx -y
sudo apt-get install python-pip -y
sudo apt-get install libmysqlclient-dev -y
sudo apt-get install supervisor -y

# Install Python packages
sudo pip install flask
sudo pip install flask-mysql
sudo pip install gunicorn

# Get app and position config files
sudo git clone https://github.com/neilpeterson/flask-voting-app.git /opt/vote-app
sudo cp /opt/vote-app/deployment/custom-script/default /etc/nginx/sites-available/
sudo cp /opt/vote-app/deployment/custom-script/supervisor-config.conf /etc/supervisor/conf.d/

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start azurevote

# Reload NGINX
sudo nginx -s reload

