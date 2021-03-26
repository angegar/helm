build:
	docker build -t angegar/helm .

alias: local_folder
	@echo "\e[32mRemove existing helm alias\e[39m"
	sed -i '/alias helm=/d' ~/.bash_aliases

	@echo "\e[32mCreate helm alias\e[39m"
	echo 'alias helm='\''docker run -it --rm -v $$(pwd):/workdir -v $$HOME/.kube:/root/.kube -v $$HOME/.cache/helm:/root/.cache/helm -v $$HOME/.config/helm:/root/.config/helm -v $$HOME/.local/share/helm:/root/.local.share/helm angegar/helm "$$@"'\''' >> ~/.bash_aliases

local_folder:
	@echo  "\e[32mEnsure local folder are presents\e[39m"
	mkdir -p $$HOME/.kube
	mkdir -p $$HOME/.cache/helm
	mkdir -p $$HOME/.config/helm
	mkdir -p $$HOME/.local/share/helm