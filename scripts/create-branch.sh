#!/bin/bash

# Get the current version from pyproject.toml
CURRENT_VERSION=$(python -c "import tomllib; print(tomllib.loads(open('pyproject.toml').read())['tool']['poetry']['version'])")

# Select branch type
PS3="Select branch type: "
options=("feature" "release" "temp")
select opt in "${options[@]}"
do
    case $opt in
        "feature"|"release"|"temp")
            BRANCH_TYPE=$opt
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

# Determine the base branch for checkout based on branch type
case $BRANCH_TYPE in
    "feature")
        BASE_BRANCH="dev"
        ;;
    "temp")
        BASE_BRANCH=$(git branch --show-current)  # Current branch
        ;;
    "release")
        PS3="Select release type: "
        options=("final" "a" "b" "rc" "post" "dev")
        select opt in "${options[@]}"
        do
            case $opt in
                "final"|"a"|"b"|"rc"|"dev")
                    RELEASE_TYPE=$opt
                    BASE_BRANCH="dev"
                    break
                    ;;
                "post")
                    RELEASE_TYPE=$opt
                    BASE_BRANCH="main"
                    break
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done
        ;;
esac

# Increment the version number according to PEP 440 for release branches
if [ "$BRANCH_TYPE" == "release" ]; then
    cd scripts || exit
    if ! NEW_VERSION=$(python -c "import increment_version; print(increment_version.increment_version('$CURRENT_VERSION', '$RELEASE_TYPE'))"); then
        echo "Error incrementing version number"
        exit 1
    fi
    cd .. || exit
    BRANCH_NAME="$BRANCH_TYPE/$NEW_VERSION"

    # Update the version in pyproject.toml
    sed -i.bak "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml && rm pyproject.toml.bak

    # Commit the changes
    git add pyproject.toml
    git commit -m "Bumped version number to $NEW_VERSION"
elif [ "$BRANCH_TYPE" == "feature" ]; then
    read -rp "Enter feature name: " FEATURE_NAME
    BRANCH_NAME="$BRANCH_TYPE/${FEATURE_NAME// /-}"
else
    BRANCH_NAME="$BRANCH_TYPE/$(tr -dc 'a-z0-9' < /dev/urandom | fold -w 8 | head -n 1)"
fi

# Checkout the appropriate base branch and create the new branch
git checkout "$BASE_BRANCH"
git checkout -b "$BRANCH_NAME"

# Create a tag for release branches
if [ "$BRANCH_TYPE" == "release" ]; then
    git tag "$NEW_VERSION"
    echo "Created tag $NEW_VERSION"
fi

echo "Created new branch $BRANCH_NAME with version number $NEW_VERSION"
