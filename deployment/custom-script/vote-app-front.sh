
sudo apt-get update
sudo apt-get install nginx
sudo apt-get install python-pip
sudo apt-get install libmysqlclient-dev



sudo tee etc/nginx/sites-available/default
server {
listen 80;
location / {
    proxy_pass http://localhost:5000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection keep-alive;
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
}
}


sudo pip install flask
sudo pip install flask-mysql
sudo git clone https://github.com/neilpeterson/flask-voting-app.git /opt/vote-app
python /opt/vote-app/main.py