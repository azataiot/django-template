import os

import requests

# Get the GitHub token and repository from the environment
token = os.environ["GITHUB_TOKEN"]
repository = os.environ["GITHUB_REPOSITORY"]

# The GitHub GraphQL API endpoint
url = "https://api.github.com/graphql"

# The headers to include with the request
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# The GraphQL query
query = f"""
{{
  repository(owner: "{repository.split('/')[0]}", name: "{repository.split('/')[1]}") {{
    pullRequests(states: MERGED, first: 10, orderBy: {{field: UPDATED_AT, direction: DESC}}) {{
      nodes {{
        title
        mergedAt
      }}
    }}
  }}
}}
"""

# Send the request
response = requests.post(url, headers=headers, json={"query": query})

# Get the pull requests from the response
pull_requests = response.json()["data"]["repository"]["pullRequests"]["nodes"]

# Open the changelog file
with open("CHANGELOG.md", "r+") as f:
    # Read the current contents of the file
    current_contents = f.read()

    # Move the file pointer to the beginning of the file
    f.seek(0)

    # Write the new entries to the changelog
    for pr in pull_requests:
        f.write(f"- {pr['title']} ({pr['mergedAt']})\n")

    # Write the current contents of the file
    f.write(current_contents)
