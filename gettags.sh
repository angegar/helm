#!/bin/bash


function getHelmCliTags (){
	### GitHub : Get all releases
	curl -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/helm/helm/releases | jq '.[].tag_name'
}

### DockerHub : Get image tags
#UNAME= <environment variables>
#UPASS= <environment variables>
function getContainerTags(){
	REPO=$1
	TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
	curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${UNAME}/${REPO}/tags/?page_size=10000 | jq -r '.results|.[]|.name'
}

getHelmCliTags
getContainerTags helm