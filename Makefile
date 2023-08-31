.PHONY: help
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

# -- Django --
## Generate secret key
django-secret-key:
	@python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

