[![build-publish](https://github.com/angegar/helm/actions/workflows/build-publish.yml/badge.svg)](https://github.com/angegar/helm/actions/workflows/build-publish.yml)

# Helm docker container

This repository is used to build a docker container containing Helm.
This container will then be used in a command alias to run Helm without having to locally install it.

## How to use the container

The following Helm and Kubectl local folders must exist on your host :

- $HOME/.kube
- $HOME/.cache/helm
- $HOME/.config/helm
- $HOME/.local/share/helm

```shell
docker run -it --rm -v $(pwd):/workdir -v $HOME/.kube:/root/.kube -v $HOME/.cache/helm:/root/.cache/helm -v $HOME/.config/helm:/root/.config/helm -v $HOME/.local/share/helm:/root/.local.share/helm angegar/helm version
```

## Configuration

The container can be used in an alias to simulate the Helm command installation.

1. Download the associated [GitHub repository](https://github.com/angegar/helm) content.
2. Execute the following command :

	```shell
	make alias
	```