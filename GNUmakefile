default: lint

EXISTING_VARS := $(.VARIABLES)
GITHUB_ORG := marshallford
GITHUB_REPO := terraform-ansible-k3s
CONTAINER_IMAGE := ghcr.io/$(GITHUB_ORG)/$(GITHUB_REPO)
CI_IMAGE_TAG := ci

DOCKER_FLAGS += --rm
ifeq ($(shell tty > /dev/null && echo 1 || echo 0), 1)
DOCKER_FLAGS += -i
endif

DOCKER := docker
DOCKER_RUN := $(DOCKER) run $(DOCKER_FLAGS)
DOCKER_PULL := $(DOCKER) pull -q

EDITORCONFIG_CHECKER_VERSION ?= 3.2.1
EDITORCONFIG_CHECKER_IMAGE ?= docker.io/mstruebing/editorconfig-checker:v$(EDITORCONFIG_CHECKER_VERSION)
EDITORCONFIG_CHECKER := $(DOCKER_RUN) -v=$(CURDIR):/check $(EDITORCONFIG_CHECKER_IMAGE)

YAMLLINT_VERSION ?= 0.34.0
YAMLLINT_IMAGE ?= docker.io/pipelinecomponents/yamllint:$(YAMLLINT_VERSION)
YAMLLINT := $(DOCKER_RUN) -v=$(CURDIR):/code $(YAMLLINT_IMAGE) yamllint

VENV := .venv
VENV_STAMP := $(VENV)/stamp
ACTIVATE := . $(VENV)/bin/activate

$(VENV_STAMP): requirements.txt
	test -d $(VENV_STAMP) || python3 -qm venv $(VENV)
	$(ACTIVATE); pip install -qU pip setuptools wheel
	$(ACTIVATE); pip install -qr requirements.txt
	touch $(VENV_STAMP)

.PHONY: python
python: $(VENV_STAMP)

.PHONY: pull pull/editorconfig pull/yamllint
pull: pull/editorconfig pull/yamllint

pull/editorconfig:
	$(DOCKER_PULL) $(EDITORCONFIG_CHECKER_IMAGE)

pull/yamllint:
	$(DOCKER_PULL) $(YAMLLINT_IMAGE)

.PHONY: lint lint/terraform lint/editorconfig lint/yamllint lint/ansible
lint: lint/terraform lint/editorconfig lint/yamllint lint/ansible

lint/terraform:
	terraform fmt -recursive -check

lint/editorconfig:
	$(EDITORCONFIG_CHECKER)

lint/yamllint:
	$(YAMLLINT) .

lint/ansible: python
	$(ACTIVATE); ansible-lint

.PHONY: build build/context/stamp build/context build/image/stamp build/image
build: build/image

BUILD_CONTEXT := container-image/context
BUILD_CONTEXT_STAMP := container-image/context.stamp

build/context/stamp:
	touch $(BUILD_CONTEXT_STAMP)

$(BUILD_CONTEXT_STAMP): python container-image/execution-environment.yaml
	$(ACTIVATE); ansible-builder create -f container-image/execution-environment.yaml -c $(BUILD_CONTEXT) --output-filename Dockerfile
	$(MAKE) build/context/stamp

build/context: $(BUILD_CONTEXT_STAMP)

BUILD_IMAGE_STAMP := container-image/build.stamp

build/image/stamp:
	touch $(BUILD_IMAGE_STAMP)

$(BUILD_IMAGE_STAMP): $(shell find $(BUILD_CONTEXT) -type f)
	$(DOCKER) build -t $(CONTAINER_IMAGE):$(CI_IMAGE_TAG) $(BUILD_CONTEXT) --no-cache --pull
	$(MAKE) build/image/stamp

build/image: $(BUILD_IMAGE_STAMP)

.PHONY: vars/github

vars/github:
	$(foreach v, $(filter-out $(EXISTING_VARS) EXISTING_VARS,$(.VARIABLES)), \
	$(info echo "MAKEFILE_$(v)=$($(v))" >> $$GITHUB_ENV))
