
sudo apt-get update
sudo apt-get install nginx
sudo apt-get install python-pip
sudo apt-get install libmysqlclient-dev

sudo pip install flask
sudo pip install flask-mysql

sudo git clone https://github.com/neilpeterson/flask-voting-app.git /opt/vote-app
sudo cp /opt/vote-app/deployment/custom-script/default /etc/nginx/sites-available/
sudo nginx -s reload

python /opt/vote-app/main.py