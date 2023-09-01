#!/bin/bash

# Get the current version from pyproject.toml
CURRENT_VERSION=$(grep -oP '(?<=version = ")[^"]*' pyproject.toml)

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
    NEW_VERSION=$(python -c "import increment_version; print(increment_version.increment_version('$CURRENT_VERSION', '$RELEASE_TYPE'))")
    BRANCH_NAME="$BRANCH_TYPE-$NEW_VERSION"
elif [ "$BRANCH_TYPE" == "hotfix" ]; then
    NEW_VERSION=$(python -c "import increment_version; print(increment_version.increment_version('$CURRENT_VERSION', 'final'))")
    BRANCH_NAME="$BRANCH_TYPE-$NEW_VERSION"
elif [ "$BRANCH_TYPE" == "feature" ]; then
    # shellcheck disable=SC2162
    read -p "Enter feature name: " FEATURE_NAME
    # shellcheck disable=SC2001
    # shellcheck disable=SC2086
    BRANCH_NAME="$BRANCH_TYPE-$(echo $FEATURE_NAME | sed 's/ /-/g')"
else
    # shellcheck disable=SC2002
    BRANCH_NAME="$BRANCH_TYPE-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
fi

# Update the version in pyproject.toml
sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml

# Create and switch to the new branch
git checkout -b "$BRANCH_NAME"

# Commit the changes
git add pyproject.toml
git commit -m "Bumped version number to $NEW_VERSION"

echo "Created new branch $BRANCH_NAME with version number $NEW_VERSION"
