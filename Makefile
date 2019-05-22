container_name := docker-pyenv
artifactory_url := index.docker.io

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION     ?= 0.1.0


TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

bash:
	docker run --rm -i -t --entrypoint "bash" $(artifactory_url)/$(container_name):latest -l

build:
	docker build --tag $(artifactory_url)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):latest
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):$(TAG)

build-force:
	docker build --rm --force-rm --pull --no-cache -t $(artifactory_url)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):latest
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):$(TAG)

tag:
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):latest
	docker tag $(artifactory_url)/$(container_name):$(GIT_SHA) $(artifactory_url)/$(container_name):$(TAG)

build-push: build tag
	docker push $(artifactory_url)/$(container_name):latest
	docker push $(artifactory_url)/$(container_name):$(GIT_SHA)
	docker push $(artifactory_url)/$(container_name):$(TAG)

push:
	docker push $(artifactory_url)/$(container_name):latest
	docker push $(artifactory_url)/$(container_name):$(GIT_SHA)
	docker push $(artifactory_url)/$(container_name):$(TAG)

push-force: build-force push

release: push
	git tag $(VERSION)
	git push upstream --tags

ci:
	docker run --rm -w /app \
	-v "$(CURRENT_DIR):/app" \
	$(artifactory_url)/$(container_name):$(GIT_SHA) --version
