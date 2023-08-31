import os
import re
from pathlib import Path

import requests

BASE_DIR = Path(__file__).resolve().parent.parent


def get_latest_bootstrap_version():
    response = requests.get("https://registry.npmjs.org/bootstrap")
    data = response.json()
    latest_version = data["dist-tags"]["latest"]
    return latest_version


def get_current_bootstrap_version(css_path):
    # Read the bootstrap.min.css file to extract the current version
    with open(os.path.join(css_path, "bootstrap.min.css")) as file:
        content = file.read()
        match = re.search(r"Bootstrap\s+v(\d+\.\d+\.\d+)", content)
        if match:
            return match.group(1)
    return None


def download_and_replace_bootstrap_files(css_path, js_path, version):
    # URLs for the Bootstrap files on the official CDN
    css_url = (
        f"https://stackpath.bootstrapcdn.com/bootstrap/{version}/css/bootstrap.min.css"
    )
    js_url = (
        f"https://stackpath.bootstrapcdn.com/bootstrap/{version}/js/bootstrap"
        f".bundle.min.js"
    )

    # Download and replace the CSS file
    response_css = requests.get(css_url)
    with open(os.path.join(css_path, "bootstrap.min.css"), "wb") as file:
        file.write(response_css.content)

    # Download and replace the JS file
    response_js = requests.get(js_url)
    with open(os.path.join(js_path, "bootstrap.bundle.min.js"), "wb") as file:
        file.write(response_js.content)


def main():
    css_path = BASE_DIR / "project/assets/css"
    js_path = BASE_DIR / "project/assets/js"

    latest_version = get_latest_bootstrap_version()
    current_version = get_current_bootstrap_version(css_path)

    if not current_version:
        print("Could not determine the current version of Bootstrap. Exiting.")
        return

    if latest_version != current_version:
        download_and_replace_bootstrap_files(css_path, js_path, latest_version)
        print(f"Bootstrap updated to version {latest_version}")
    else:
        print("Bootstrap is already up to date")


if __name__ == "__main__":
    main()
