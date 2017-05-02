# Demo Azure voting app

Simple Flask app for demonstrating Azure IaaS architectural configurations. The voting app consists of a Flask app and a MySQL database.

![](./vote-app.png)

## Deployment

Sample deployment scripts and cloud-init files are found in the deployment folder.

Run these commands to deploy to your Azure subscription.

```
curl https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/cloud-init-front.txt > cloud-init-front.txt
curl https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/cloud-init-back.txt > cloud-init-back.txt
curl https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/deploy-app-secured.sh > deploy-app-secured.sh
bash ./deploy-app-secured.sh
``` 

When deploying, the password value can be stored in Azure Key vault for maximum security. This configuration is not demonstrated in the deployment scripts. 

## Configuration

The `config_file.cfg` can be found at the root of the repo. This file can be used to configure MySQL connection string and basic UI settings.

| Configuration | Description |
|----|----|
| TITLE | Title to be displayed in app and on title bar. |
| VOTE1VALUE | This value will display as the first voting option. |
| VOTE2VALUE| This value will display as the second voting option. |
| SHOWHOST | If set to true, the title will be replaced with the name of the system or container hosting the application.  |

```
# MySql Configuration
MYSQL_DATABASE_USER = 'dbuser'
MYSQL_DATABASE_PASSWORD = 'Password12'
MYSQL_DATABASE_DB = 'azurevote'
MYSQL_DATABASE_HOST = '10.0.0.5'

# UI Configurations
TITLE = 'Azure Voting App'
VOTE1VALUE = 'Cats'
VOTE2VALUE = 'Dogs'
SHOWHOST = 'false'
```