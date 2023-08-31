.PHONY: help, pre-commit, push, prdev, remove-branch, pr, update-dev, django-secret-key
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


# -- Git and Github --
## Run pre-commit hooks
pre-commit:
	@echo "Running pre-commit..."
	@pre-commit run --all-files
	@echo "Done!"

## Push current branch
push:
	@if git diff-index --quiet HEAD -- && git diff --staged --quiet; then \
		echo "Pushing to $(shell git rev-parse --abbrev-ref HEAD) branch..."; \
		git push origin $(shell git rev-parse --abbrev-ref HEAD); \
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
		git branch -d $$BRANCH_TO_DELETE; \
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


## Update dev branch from main
update-dev:
	@echo "Updating dev branch from main..."
	@git config pull.rebase false
	@git branch -D update-dev
	@# Create a new branch from main
	@git checkout -b update-dev
	@git pull origin main
	@git add .
	@git commit -m "update dev from main"
	@$(MAKE) push
	@# Call the prdev target to create a new PR to dev from the current branch
	@$(MAKE) prdev
	@# If everything is okay, call the remove-branch target on itself
	@$(MAKE) remove-branch
	@echo "Done!"


# -- Django --
## Generate secret key
django-secret-key:
	@python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
