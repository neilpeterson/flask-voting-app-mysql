# Demo Azure voting app

Simple Flask app for demonstrating Azure IaaS architectural configurations. The voting app consists of a Flask app and a MySQL database.

![](./readme-media/vote-app.png)

## Configuration

The `config_file.cfg` can be found at the root of the repo. This file is used to configure the MySQL connection string and basic UI settings.

Sample File:

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

UI Configuration:

| Configuration | Description |
|----|----|
| TITLE | Title to be displayed in app and on title bar. |
| VOTE1VALUE | This value will display as the first voting option. |
| VOTE2VALUE| This value will display as the second voting option. |
| SHOWHOST | If set to true, the title will be replaced with the name of the system or container hosting the application.  |


## Samples Deployment

Sample deployment scripts are found in the deployment folder. To deploy any of these, copy the command and run in a bash shell.

Sample on Virtual Machines - [more information](./deployment/azure-vm)

```
curl http://bit.ly/2pRhDYD | bash
```

Sample on Virtual Machine Scale Set - [more information](./deployment/azure-vmss)

```
curl http://bit.ly/2pRhDYD | bash
```

Sample in Docker Swarm Mode - [more information](./deployment/azure-docker-swarm)

```
curl http://bit.ly/2qXZ997 | bash
```