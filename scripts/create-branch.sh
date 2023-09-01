#!/bin/bash

# Get the current version from pyproject.toml
CURRENT_VERSION=$(python -c "import tomllib; print(tomllib.loads(open('pyproject.toml').read())['tool']['poetry']['version'])")


# Select branch type
PS3="Select branch type: "
options=("release" "hotfix" "feature" "temp")
select opt in "${options[@]}"
do
    case $opt in
        "release"|"hotfix"|"feature"|"temp")
            BRANCH_TYPE=$opt
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

# Select release type
if [ "$BRANCH_TYPE" == "release" ]; then
    PS3="Select release type: "
    options=("alpha" "beta" "candidate" "breaking" "final")
    select opt in "${options[@]}"
    do
        case $opt in
            "alpha"|"beta"|"candidate"|"breaking"|"final")
                RELEASE_TYPE=$opt
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
fi

# Increment the version number according to PEP 440
if [ "$BRANCH_TYPE" == "release" ]; then
    cd scripts || exit
    NEW_VERSION=$(python -c "import increment_version; print(increment_version.increment_version('$CURRENT_VERSION', '$RELEASE_TYPE'))")
    cd .. || exit
    BRANCH_NAME="$BRANCH_TYPE-$NEW_VERSION"
elif [ "$BRANCH_TYPE" == "hotfix" ]; then
    cd scripts || exit
    NEW_VERSION=$(python -c "import increment_version; print(increment_version.increment_version('$CURRENT_VERSION', 'final'))")
    cd .. || exit
    BRANCH_NAME="$BRANCH_TYPE-$NEW_VERSION"
elif [ "$BRANCH_TYPE" == "feature" ]; then
    read -p "Enter feature name: " FEATURE_NAME
    BRANCH_NAME="$BRANCH_TYPE-$(echo $FEATURE_NAME | sed 's/ /-/g')"
else
    BRANCH_NAME="$BRANCH_TYPE-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
fi

# Update the version in pyproject.toml
sed -i.bak "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml && rm pyproject.toml.bak

# Create and switch to the new branch
git checkout -b "$BRANCH_NAME"

# Commit the changes
git add pyproject.toml
git commit -m "Bumped version number to $NEW_VERSION"

echo "Created new branch $BRANCH_NAME with version number $NEW_VERSION"
