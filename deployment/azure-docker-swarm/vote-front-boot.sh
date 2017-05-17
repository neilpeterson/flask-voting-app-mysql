# Update Azure vote config file
sed -i "s/<user>/$user/g" /opt/vote-app/config_file.cfg
sed -i "s/<password>/$password/g" /opt/vote-app/config_file.cfg
sed -i "s/<ip>/$ip/g" /opt/vote-app/config_file.cfg

# Start app
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf