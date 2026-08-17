.PHONY: default
default: python

.DELETE_ON_ERROR:

UV ?= uv
VENV := .venv
VENV_STAMP := $(VENV)/stamp

$(VENV_STAMP): pyproject.toml $(wildcard uv.lock)
	$(UV) venv $(VENV) --clear
	$(UV) sync
	touch $(VENV_STAMP)

.PHONY: python
python: $(VENV_STAMP)

.PHONY: clean clean/python clean/terraform
clean: clean/python clean/terraform

clean/python:
	rm -rf $(VENV)

clean/terraform:
	rm -rf .terraform
