# Docker Swarm Mode running Azure Vote app as a service

This example completes the following:

- Deploys a VM, installs MySQL and prepares the Azure vote app back-end.
- Deploys a fully configured Docker Swarm (swarm mode)
- Created a Docker service for the Azure vote app back end

## Deploy example

Run the following command to deploy this example.

```
curl https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/azure-docker-swarm/azure-vote-docker-service.sh | bash
```
