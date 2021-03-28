#!/bin/bash


function getHelmCliTags () {
	### GitHub : Get all releases
	curl -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/helm/helm/releases | jq '.[].tag_name' | sed -e s/v//g -e /-rc/d -e s/\"//g | sort -g
}

### DockerHub : Get image tags
#UNAME= <environment variables>
#UPASS= <environment variables>
function getContainerTags () {
	REPO=$1
	TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
	curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${UNAME}/${REPO}/tags/?page_size=10000 | jq -r '.results|.[]|.name' | sort -g
}

## Get tags which are on the cli and not in the container
function getAddedDiffTags () {
	getHelmCliTags > helmtags.txt
	getContainerTags helm > helmcontainer.txt
	diff helmcontainer.txt helmtags.txt | grep ">" | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/g'
}


function buildImages () {

	GREEN='\e[32m'
	NC='\e[39m'
	DOCKER_BUILDKIT=0
	# Avoid all the HTTP call in executing the command only once
	getAddedDiffTags > tags_list.txt


	if [ $(cat tags_list.txt | wc -l) -gt 0 ]
	then

		echo -e "${GREEN} Docker Login $tag${NC}"
		docker login -u ${UNAME} -p ${UPASS}
		
		# Get latest tag
		TAG_LATEST=$(tail -1 tags_list.txt)
		echo -e "${GREEN} The latest version will be $TAG_LATEST${NC}"

		# Build all the images
		for tag in $(cat tags_list.txt)
		do
			# Check if there is a downloadable linux archive
			HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}"  https://get.helm.sh/helm-v${tag}-linux-amd64.tar.gz)
			if [ $HTTP_STATUS == "200" ]
			then
				# Remind the tags to clean the local image at the end
				echo $tag >> ./toClean.txt

				# Build the images
				echo -e "${GREEN} Build Helm version $tag${NC}"
				docker build -t "angegar/helm:$tag"  --build-arg HELM_VERSION="$tag" .

				# Build the latest tag tag
				if [ "$tag" == "$TAG_LATEST" ]; then
					docker build -t "angegar/helm:latest" --build-arg HELM_VERSION="$tag" .
				fi 
			else
				echo -e "${GREEN} No linux amd64 source for the Helm version $tag${NC}"
			fi
		done

		# clean temporary file
		# rm -rf tags_list.txt

		if [ -f ./toClean.txt ] &&  [ $(cat ./toClean.txt | wc -l) -gt 0 ]; then
			echo -e "${GREEN} Publish images $tag${NC}"
			docker push --all-tags "angegar/helm"
		fi
	else
		echo -e "${GREEN} Nothing to do !!!${NC}"
	fi
}

function cleanLocalImages() {
	echo -e "${GREEN} Clean up local docker images${NC}"
	docker rmi $(docker images  angegar/helm  --format "{{.ID}}") 2>/dev/null || echo -e "${GREEN} Nothing to clean${NC}" 
	rm -f helmcontainer.txt
	rm -f helmtags.txt
	rm -f toClean.txt
}

buildImages
cleanLocalImages