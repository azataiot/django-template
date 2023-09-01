.PHONY: help, pre-commit, push, prdev, remove-branch, pr, update-branch-dev, django-secret-key, docs, branch, install, lint, update, install-dev, migrate, run, dev, requirements
.DEFAULT_GOAL := help

## This help screen
help:
	@echo "Available targets:"
	@awk '/^[a-zA-Z\-\_0-9%:\\ ]+/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = $$1; \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	    gsub("\\\\", "", helpCommand); \
	    gsub(":+$$", "", helpCommand); \
	    printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
	  } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u

# -- Update && Upgrade --
## Update (check for updates for django-template)
update:
	@echo "Checking for updates..."
	@REMOTE_VERSION=$$(curl -s https://raw.githubusercontent.com/azataiot/django-template/main/pyproject.toml | grep '^version =' | awk -F\" '{print $$2}'); \
	LOCAL_VERSION=$$(grep '^version =' pyproject.toml | awk -F\" '{print $$2}'); \
	if [ "$$REMOTE_VERSION" != "$$LOCAL_VERSION" ]; then \
		echo "Update available: $$REMOTE_VERSION (current version: $$LOCAL_VERSION)"; \
	else \
		echo "You are using the latest version: $$LOCAL_VERSION"; \
	fi


# -- Dependency --
## Install dependencies (only main)
install:
	@command -v poetry >/dev/null 2>&1 || { echo >&2 "Poetry is not installed. Aborting."; exit 1; }
	@echo "Installing dependencies..."
	@poetry install --only main
	@echo "Done!"

## Install dependencies (development and testing)
install-dev:
	@command -v poetry >/dev/null 2>&1 || { echo >&2 "Poetry is not installed. Aborting."; exit 1; }
	@echo "Installing dependencies..."
	@poetry install
	@echo "Done!"

## Export dependencies to requirements.txt
requirements:
	@echo "Exporting dependencies to requirements.txt..."
	@poetry export --only main -f requirements.txt --output requirements/requirements.txt --without-hashes
	@poetry export --only dev -f requirements.txt --output requirements/dev-requirements.txt --without-hashes
	@echo "Done!"


# -- Code Quality --
## Linting code (ruff, isort)
lint:
	@echo "Linting code..."
	@poetry run ruff check .
	@poetry run isort .
	@echo "Done!"


# -- Git and Github --
## Run pre-commit hooks
pre-commit:
	@echo "Running pre-commit..."
	@pre-commit run --all-files
	@echo "Done!"

## Push current branch
push:
	@if git diff-index --quiet HEAD -- && git diff --staged --quiet; then \
		BRANCH_NAME=$(shell git rev-parse --abbrev-ref HEAD); \
		echo "Pushing to $$BRANCH_NAME branch..."; \
		git push origin $$BRANCH_NAME; \
		if [[ $$BRANCH_NAME == release-* ]] || [[ $$BRANCH_NAME == hotfix-* ]]; then \
			echo "Pushing tags..."; \
			git push --tags; \
		fi; \
		echo "Done!"; \
	else \
		echo "Uncommitted or unstaged changes found. Please commit and stage your changes before pushing."; \
	fi



## Create PR to dev branch
prdev:
	@if git diff-index --quiet HEAD --; then \
		echo "Creating PR to dev branch..."; \
		gh pr create --base dev --head $(shell git rev-parse --abbrev-ref HEAD); \
		echo "Done!"; \
	else \
		echo "Uncommitted changes found. Please commit your changes before creating a PR."; \
	fi

## Remove current branch
remove-branch:
	@BRANCH_TO_DELETE=$(shell git rev-parse --abbrev-ref HEAD); \
	echo "Branch to delete: $$BRANCH_TO_DELETE"; \
	if [ "$$BRANCH_TO_DELETE" = "main" ] || [ "$$BRANCH_TO_DELETE" = "dev" ] || [ "$$BRANCH_TO_DELETE" = "release" ] || [[ "$$BRANCH_TO_DELETE" == project* ]]; then \
		echo "Cannot delete branch $$BRANCH_TO_DELETE."; \
	elif ! git diff-index --quiet HEAD -- || ! git diff --staged --quiet || [ "$$(git rev-list $$BRANCH_TO_DELETE..origin/$$BRANCH_TO_DELETE --count)" != "0" ]; then \
		echo "Uncommitted, unstaged, or unpushed changes found. Please commit, stage, and push your changes before deleting the branch."; \
	else \
		git checkout dev; \
		git push origin -d $$BRANCH_TO_DELETE; \
		git branch -D $$BRANCH_TO_DELETE; \
		echo "Branch $$BRANCH_TO_DELETE deleted."; \
		git pull origin dev; \
		echo "branch `dev` updated."; \
		echo "Done!"; \
	fi


## Create PR from dev to main branch
pr:
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" = "dev" ]; then \
		if git diff-index --quiet HEAD --; then \
			echo "Creating PR from dev to main branch..."; \
			gh pr create -f --base main --head dev; \
			echo "Done!"; \
		else \
			echo "Uncommitted changes found. Please commit your changes before creating a PR."; \
		fi \
	else \
		echo "Current branch is not dev. Please switch to the dev branch before creating a PR to main."; \
	fi

## Update dev branch
update-branch-dev:
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" = "dev" ]; then \
		if git diff-index --quiet HEAD --; then \
			echo "Updating dev branch..."; \
			git pull origin main; \
			echo "Done!"; \
			$(MAKE) push; \
		else \
			echo "Uncommitted changes found. Please commit your changes before updating dev."; \
		fi; \
	else \
		echo "Current branch is not dev. Please switch to the dev branch before updating dev."; \
	fi

##
branch:
	scripts/create-branch.sh

# -- Django --
## Generate secret key
django-secret-key:
	@python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

## Run Django migrations
migrate:
	@echo "Running Django migrations..."
	@PYTHONPATH=$(PWD) poetry run python project/manage.py makemigrations
	@PYTHONPATH=$(PWD) poetry run python project/manage.py migrate

## Run Django server (with sqlite3)
run:
	@echo "Starting Django server..."
	@PYTHONPATH=$(PWD) poetry run python project/manage.py runserver

## Run Django server (with postgres database)
dev:
	@poetry run python project/manage.py runserver

# -- Docs --
## Build docs
docs: ## Serve documentation locally
	cd docs && mkdocs serve -a localhost:8090
