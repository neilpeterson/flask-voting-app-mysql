
sudo apt-get update
sudo apt-get install nginx
sudo apt-get install python-pip
sudo apt-get install libmysqlclient-dev
# Git clone nginx config
sudo pip install flask
sudo pip install flask-mysql
sudo git clone https://github.com/neilpeterson/flask-voting-app.git /opt/vote-app
python /opt/vote-app/main.py