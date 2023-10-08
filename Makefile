SHELL:=/usr/bin/env bash

VENV_DIR=.venv
VENV_BIN=$(VENV_DIR)/bin

PIP=$(VENV_BIN)/pip
PYTHON_EXE=python3.7
PYTHON=$(VENV_BIN)/python3
PYENV_INSTALL=0
PYTHON_INSTALL=0
PYTHON_VERSION=$(shell cat .python-version 2> /dev/null || echo '3.7.13')
IS_CORRECT_PYTHON_VERSION=$(shell $(PYTHON_EXE) --version | grep -oE '$(PYTHON_VERSION)')

define MSG_INSTALL_PYTHON3

Python3 must be at version $(PYTHON_VERSION) or greater.
Install by running 'install_python_pyenv.sh' located in the 'scripts' directory.

./scripts/install_python_pyenv.sh

endef


ifeq "$(IS_CORRECT_PYTHON_VERSION)" ""
$(warning "$(MSG_INSTALL_PYTHON3)")
endif


.PHONY: all
all: test

$(VENV_DIR):
	@echo 'Creating a virtual environment'
	@$(PYTHON_EXE) -m venv --prompt $(notdir $(CURDIR)) ./$(VENV_DIR)
	@echo 'Environment created. Run "source ./$(VENV_DIR)/bin/activate" or "make shell" to activate the virtual environment.\n"deactivate" or "exit" to exit it.'

.update-pip: ## Update pip
	@$(PIP) install -U 'pip'

.install-deps-dev: $(VENV_DIR)
	@$(PIP) install --require-virtualenv --requirement requirements-dev.txt
	@touch .install-deps-dev

.develop: .install-deps-dev
	@$(PIP) install --require-virtualenv --editable .
	@touch .develop

.PHONY: install-dev
install-dev: .develop ## Install development environment, in a virtual environment.

.git/hooks/pre-commit: .develop
	@$(VENV_BIN)/pre-commit install
	#&& \
	#$(VENV_BIN)/pre-commit autoupdate

install-pre-commit: .git/hooks/pre-commit ## Install Git pre-commit hooks to run linter and mypy


.PHONY: install-prod
install-prod:  ## Install non-dev environment
	@python3 -m pip install --target . --requirement requirements.txt

.PHONY: run-prod
run-prod:	## Run prod server
	export LOGLEVEL=error && python3 ./src/main.py

.PHONY: run-dev
run-dev: $(VENV_DIR)	## Run dev server
	export LOGLEVEL=debug && $(PYTHON) ./src/main.py

.PHONY: run-test
run-test: $(VENV_DIR)	## Run in debug mode, and log to a file.
	/usr/bin/env LOGLEVEL=debug $(PYTHON) ./src/main.py 2>&1 | tee /tmp/logs_$$(date +%m-%d-%Y_%H:%M:%S).txt

.PHONY: run
run:	## Run server
	export LOGLEVEL=debug && $(PYTHON) ./src/main.py


.PHONY: install-dev-minimal
install-dev-minimal: $(VENV_DIR) ## Install Git pre-commit hooks for the devs that want to develop on the BBB
	@$(PIP) install --require-virtualenv pre-commit
	@$(PIP) install --require-virtualenv -r requirements-typing.txt
	@$(PIP) install --require-virtualenv -r requirements.txt
	@$(PIP) install --require-virtualenv --editable .
	@$(VENV_BIN)/pre-commit install #&& $(VENV_BIN)/pre-commit autoupdate

.PHONY: install-pyenv
install-pyenv:  ## Install Pyenv
	@curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

.PHONY: install-python
install-python:  ## Install Python
	pyenv install $(PYTHON_VERSION)
	pyenv local


.PHONY: fmt format
fmt format: ## Format code
	@$(PYTHON) -m pre_commit run --all-files --show-diff-on-failure


.PHONY: mypy
mypy:  ## Static type checking
	@$(VENV_BIN)/mypy || python3 -m mypy

.PHONY: lint
lint: fmt mypy  ## Lint source code


.PHONY: test
test: .develop  ## Run unit tests
	@$(VENV_BIN)/pytest -q

.PHONY: vtest
vtest: .develop ## Verbose tests
	@$(VENV_BIN)/pytest -v

.PHONY: vvtest
vvtest: .develop ## More verbose tests
	@$(VENV_BIN)/pytest -vv

.PHONY: dbtest
dbtest: .develop ## Debuggable tests
	@$(VENV_BIN)/pytest --capture=no -vv

.PHONY: viewCoverage
viewCoverage: htmlcov ## View the last coverage run
	open -a "Google Chrome" htmlcov/index.html

.PHONY: shell
shell: $(VENV_DIR) ## Open a virtual environment
	@echo 'Activating virtual environment.' && $(SHELL) --init-file <(echo ". ~/.bashrc; . $(VENV_BIN)/activate;")


.PHONY: clean
clean: ## Remove all generated files and folders
	@$(VENV_BIN)/pre-commit uninstall || true
	@rm -rf .venv
	@rm -rf `find . -name __pycache__`
	@rm -f `find . -type f -name '*.py[co]' `
	@rm -f .coverage
	@rm -rf htmlcov
	@rm -rf build
	@rm -rf cover
	@rm -f .develop
	@rm -f .flake
	@rm -rf *.egg-info
	@rm -f .install-deps-dev
	@rm -f .install-deps
	@rm -rf .mypy_cache
	@python setup.py clean || true
	@pkill -SIGTERM socat
	@rm -rf .eggs
	@rm -rf src/*.egg-info
	@rm -rf .pytest_cache/

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY : help
help :
	@grep -E '^[[:alnum:]_-]+[[:blank:]]?:.*##' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# @if ! command -v pre-commit &> /dev/null; then echo You need to add "'""${HOME}/.local/bin""'" to your path. Or if you are using Pyenv run "'"pyenv rehash"'" ; false ; fi
