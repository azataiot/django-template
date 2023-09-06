import random
import string
import subprocess
import tomllib
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent


def get_current_version():
    with open(ROOT_DIR / "pyproject.toml", "rb") as file:
        data = tomllib.load(file)
        return data["tool"]["poetry"]["version"]


def select_branch_type():
    options = ["feature", "release", "temp"]
    while True:
        for idx, opt in enumerate(options, 1):
            print(f"{idx}. {opt}")
        try:
            choice = input(f"Select branch type (default is {options[0]}): ")
            if not choice:
                return options[0]
            choice = int(choice)
            if 1 <= choice <= len(options):
                return options[choice - 1]
            else:
                print(f"Please select a number between 1 and {len(options)}")
        except ValueError:
            print("Please enter a valid number.")


def select_release_type():
    options = ["final", "a", "b", "rc", "post", "dev"]
    for idx, opt in enumerate(options, 1):
        print(f"{idx}. {opt}")
    choice = input(f"Select release type (default is {options[0]}): ")
    if not choice:
        return options[0]
    return options[int(choice) - 1]


def get_base_branch(
    branch_type, release_type=None
):  # Add release_type as an optional argument
    if branch_type == "feature":
        return "dev"
    elif branch_type == "temp":
        return subprocess.getoutput("git branch --show-current")
    elif branch_type == "release":
        if not release_type:  # If release_type is not provided, get it
            release_type = select_release_type()
        if release_type in ["final", "a", "b", "rc", "dev"]:
            return "dev"
        elif release_type == "post":
            return "main"


def main():
    try:
        release_type = None
        new_version = None
        current_version = get_current_version()
        branch_type = select_branch_type()  # ["feature", "release", "temp"]
        if branch_type == "release":
            release_type = (
                select_release_type()
            )  # ["final", "a", "b", "rc", "post", "dev"]
        base_branch = get_base_branch(
            branch_type, release_type
        )  # Pass release_type as an argument

        if branch_type == "release":
            from pep440.pep440 import get_next_pep440_version

            new_version = get_next_pep440_version(current_version, release_type)
            branch_name = f"{branch_type}/{new_version}"

            # Commit the changes
            subprocess.run(["git", "add", "pyproject.toml"])
            subprocess.run(
                ["git", "commit", "-m", f"Bumped version number to {new_version}"]
            )

        elif branch_type == "feature":
            feature_name = input("Enter feature name (default is refactoring): ")
            if not feature_name:
                feature_name = "refactoring"
            branch_name = f"{branch_type}/{feature_name.replace(' ', '-')}"
        else:
            branch_name = f"{branch_type}/{''.join(random.choices(string.ascii_lowercase + string.digits, k=8))}"

        # Checkout the appropriate base branch and create the new branch
        subprocess.run(["git", "checkout", base_branch])
        subprocess.run(["git", "checkout", "-b", branch_name])

        # Create a tag for release branches
        if branch_type == "release" and new_version:
            subprocess.run(["git", "tag", new_version])
            print(f"Created tag {new_version}")

        print(
            f"Created new branch {branch_name} with version number {new_version if branch_type == 'release' else ''}"
        )

    except KeyboardInterrupt:
        print("\nOperation interrupted by user. Cleaning up...")


if __name__ == "__main__":
    main()
