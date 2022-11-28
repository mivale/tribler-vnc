# Prevents one to use @ before each statement
ifndef VERBOSE
.SILENT:
endif
MAKEFLAGS += --no-print-directory

TRIBLER_VERSION := 7.12.1

NAME := tribler-vnc
IMAGE_NAME := mivale/$(NAME)
IMAGE_VERSION := latest

.PHONY: help
help: ## Show this help message
	printf '\033[32mUsage: make [target] ...\033[0m\n\nAvailable targets:\n\n'
	egrep -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

fetch: ## Fetch the defined version
	echo "Fetching Tribler $(TRIBLER_VERSION)"
	test -f Tribler-v$(TRIBLER_VERSION).tar.xz || \
		curl -sLO https://github.com/Tribler/tribler/releases/download/v$(TRIBLER_VERSION)/Tribler-v$(TRIBLER_VERSION).tar.xz
	rm -rf tribler
	tar xfJ Tribler-v$(TRIBLER_VERSION).tar.xz
	make patch

patch: ## Apply our patches on the source
	cd tribler && patch -p1 < ../patches/tribler_window.py.diff

build: ## Build image
	test -d tribler || make fetch
	echo "Building $(IMAGE_NAME):$(IMAGE_VERSION) from Tribler $(TRIBLER_VERSION)"
	DOCKER_BUILDKIT=1 \
		docker build \
		-t $(IMAGE_NAME):$(IMAGE_VERSION) .

run-debug: ## Run image in a fresh container (debug)
	docker run -ti --rm \
		--name $(NAME) \
		-e QT_DEBUG_PLUGINS=1 \
		-v $(PWD)/settings:/home/user/.Tribler \
		-v $(PWD)/logs:/home/user/logs \
		-v $(PWD)/downloads:/home/user/TriblerDownloads \
		-p 5900:5900 -p 20100:20100 \
		$(IMAGE_NAME):$(IMAGE_VERSION) bash

run: ## Run image in a fresh container
	docker run -d --rm \
		--name $(NAME) \
		--hostname $(NAME) \
		-v $(PWD)/settings:/home/user/.Tribler \
		-v $(PWD)/logs:/home/user/logs \
		-v $(PWD)/downloads:/home/user/TriblerDownloads \
		-p 5900:5900 -p 20100:20100 \
		$(IMAGE_NAME):$(IMAGE_VERSION)

stop: ## Stop tribler VNC
	docker stop $(NAME)

log: ## Show tribler VNC logs
	docker logs $(NAME)

shell: ## Open a shell in running container
	docker exec -ti $(NAME) bash

clean: ## Cleanup build stuff
	rm -rf tribler Tribler-v$(TRIBLER_VERSION).tar.xz
