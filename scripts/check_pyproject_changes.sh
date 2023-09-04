#!/bin/bash

# Check if pyproject.toml has changed in the staged changes
CHANGED=$(git diff --cached --name-only | grep pyproject.toml)

if [ -n "$CHANGED" ]; then
    # If pyproject.toml has changed, run the poetry hooks
    echo "pyproject.toml has changed. Running poetry lock..."
    poetry lock
    echo "pyproject.toml has changed. Running poetry export hooks..."
    poetry export -f requirements.txt --only main -o requirements/requirements.txt
    poetry export -f requirements.txt --only dev -o requirements/dev-requirements.txt
else
    echo "pyproject.toml has not changed. Skipping poetry hooks..."
fi
