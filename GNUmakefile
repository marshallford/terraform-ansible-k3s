.PHONY: default
default: lint

.DELETE_ON_ERROR:

EXISTING_VARS := $(.VARIABLES)
GITHUB_ORG := marshallford
GITHUB_REPO := terraform-ansible-k3s
RELEASE_WORKFLOW := .github/workflows/release.yaml
CONTAINER_IMAGE := ghcr.io/$(GITHUB_ORG)/$(GITHUB_REPO)
CI_IMAGE_TAG := ci

DOCKER_FLAGS += --rm
ifeq ($(shell tty > /dev/null && echo 1 || echo 0), 1)
DOCKER_FLAGS += -i
endif

DOCKER ?= docker
DOCKER_MOUNT_FLAGS := ro,z
DOCKER_RUN := $(DOCKER) run $(DOCKER_FLAGS)
DOCKER_PULL := $(DOCKER) pull -q

COSIGN ?= cosign
GH ?= gh
VERIFY_CONTAINER_IMAGE ?= $(CONTAINER_IMAGE):latest
VERIFY_CERT_IDENTITY := https://github.com/$(GITHUB_ORG)/$(GITHUB_REPO)/$(RELEASE_WORKFLOW)@refs/heads/main
VERIFY_OIDC_ISSUER := https://token.actions.githubusercontent.com
VERIFY_SIGNER_WORKFLOW := $(GITHUB_ORG)/$(GITHUB_REPO)/$(RELEASE_WORKFLOW)
VERIFY_SBOM_PREDICATE_TYPE ?= https://spdx.dev/Document/v2.3

EDITORCONFIG_CHECKER_VERSION ?= 3.11.1
EDITORCONFIG_CHECKER_IMAGE ?= docker.io/mstruebing/editorconfig-checker:v$(EDITORCONFIG_CHECKER_VERSION)
EDITORCONFIG_CHECKER := $(DOCKER_RUN) -v=$(CURDIR):/check:$(DOCKER_MOUNT_FLAGS) $(EDITORCONFIG_CHECKER_IMAGE)

YAMLLINT_VERSION ?= 0.35.13
YAMLLINT_IMAGE ?= docker.io/pipelinecomponents/yamllint:$(YAMLLINT_VERSION)
YAMLLINT := $(DOCKER_RUN) -v=$(CURDIR):/code:$(DOCKER_MOUNT_FLAGS) $(YAMLLINT_IMAGE) yamllint

UV ?= uv
VENV := .venv
VENV_STAMP := $(VENV)/stamp
ACTIVATE := . $(VENV)/bin/activate

EE_DEFINITION := container-image/execution-environment.yaml
BUILD_CONTEXT := container-image/context
BUILD_CONTEXT_STAMP := container-image/context.stamp
BUILD_IMAGE_STAMP := container-image/build.stamp

$(VENV_STAMP): pyproject.toml $(wildcard uv.lock)
	$(UV) venv $(VENV) --clear
	$(UV) sync
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

lint/ansible: $(VENV_STAMP)
	$(ACTIVATE); ansible-lint

.PHONY: fmt fmt/terraform
fmt: fmt/terraform

fmt/terraform:
	terraform fmt -recursive

TEST_EXAMPLES := $(patsubst examples/%/,test/terraform/%,$(wildcard examples/*/))

.PHONY: test test/terraform $(TEST_EXAMPLES)
test: test/terraform

test/terraform: $(TEST_EXAMPLES)

$(TEST_EXAMPLES): test/terraform/%:
	terraform -chdir=examples/$* init -backend=false -input=false
	terraform -chdir=examples/$* validate

.PHONY: verify verify/image verify/sbom
verify: verify/image verify/sbom

verify/image:
	$(COSIGN) verify $(VERIFY_CONTAINER_IMAGE) \
		--certificate-identity $(VERIFY_CERT_IDENTITY) \
		--certificate-oidc-issuer $(VERIFY_OIDC_ISSUER) > /dev/null
	$(GH) attestation verify oci://$(VERIFY_CONTAINER_IMAGE) \
		--repo $(GITHUB_ORG)/$(GITHUB_REPO) \
		--signer-workflow $(VERIFY_SIGNER_WORKFLOW)

verify/sbom:
	$(GH) attestation verify oci://$(VERIFY_CONTAINER_IMAGE) \
		--repo $(GITHUB_ORG)/$(GITHUB_REPO) \
		--signer-workflow $(VERIFY_SIGNER_WORKFLOW) \
		--predicate-type $(VERIFY_SBOM_PREDICATE_TYPE)

.PHONY: build build/context build/image
build: build/image

$(BUILD_CONTEXT_STAMP): $(VENV_STAMP) $(EE_DEFINITION)
	$(ACTIVATE); ansible-builder create -f $(EE_DEFINITION) -c $(BUILD_CONTEXT) --output-filename Dockerfile
	touch $(BUILD_CONTEXT_STAMP)

build/context: $(BUILD_CONTEXT_STAMP)

$(BUILD_IMAGE_STAMP): $(BUILD_CONTEXT_STAMP) $(wildcard $(BUILD_CONTEXT)/*)  $(wildcard $(BUILD_CONTEXT)/_build/*)
	$(DOCKER) build -t $(CONTAINER_IMAGE):$(CI_IMAGE_TAG) $(BUILD_CONTEXT) --no-cache --pull
	touch $(BUILD_IMAGE_STAMP)

build/image: $(BUILD_IMAGE_STAMP)

.PHONY: clean clean/python clean/terraform clean/ansible clean/context clean/image
clean: clean/python clean/terraform clean/ansible clean/context clean/image

clean/python:
	rm -rf $(VENV)

clean/terraform:
	rm -rf examples/*/.terraform

clean/ansible:
	rm -rf .ansible

clean/context:
	rm -rf $(BUILD_CONTEXT) $(BUILD_CONTEXT_STAMP)

clean/image:
	rm -f $(BUILD_IMAGE_STAMP)

.PHONY: vars/github
vars/github:
	$(foreach v, $(filter-out $(EXISTING_VARS) EXISTING_VARS .SHELLSTATUS,$(.VARIABLES)), \
	$(info echo "MAKEFILE_$(v)=$($(v))" >> $$GITHUB_ENV))
