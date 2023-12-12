
## Automatic Pull request Labeler

Automatically add labels to your pull requests based on file paths and extensions.

### Action Options

github-token: Token used for authentication ```[required]```
```
with:
  github-token: ${{ github.token }}
```
paths: Apply a label based on directory changes ```[optional]```
```
with:
  paths: |
  .: "root"
  Dockerfile: "docker"
  .github/workflows: "workflows"
```

This will apply the labels ```root```, ```Dockerfile```, and ```workflow``` when the pull request includes any changed files in the root of the project, a file named Dockerfile changed in the root directory, or when any file within the ```.github/workflows``` directory is changed.

Paths should start with a ```.```. For example ```src``` can be either ```src``` or ```.src``` but not ```./src```. Another example would be ```.frontend/src/components/```.
Both ```paths``` and ```languages``` need to be valid yml.

languages: Apply a label based on a file extension ```[optional]```
```
languages: |
  ts: "typescript"
  js: "javascript"
  tsx: "react"
  jsx: "react"
  yml: "config"
  yaml: "config"
  json: "config"
```
This will apply the labels if any file changes are detected with the extensions ```.ts```, ```.js```, ```.tsx```, or ```.jsx```, etc.

assign_owner: Assign the creator of the pull request as an assignee. ```[optional]```
```
assign-owner: 'true' 
```

## Labels

Labels that do not exist will be created with a random color.

## A full example using this action:
```
name: "Automatic PR Labeler"
on:
  pull_request:
    types: [opened]
permissions: // Required permissions for action to work properly
  contents: read // Read content from repository
  pull-requests: write // Read and edit pull requests
  repository-projects: read // Read GITHUB_TOKEN
jobs:
  label:
    runs-on: ubuntu-latest
    env:
      GH_TOKEN: ${{ github.token }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 // Fetch the entire history of the repository
      - name: Assign labels
        uses: shanearcaro/automatic-labeler@v2
        with:
          paths: |
            .: "root"
            Dockerfile: "docker"
            .github/workflows: "workflows"
          languages: |
            ts: "typescript"
            js: "javascript"
            tsx: "react"
            jsx: "react"
            yml: "config"
            yaml: "config"
            json: "config"
            md: "documentation"
            sh: "scripting"
          assign-owner: 'true'
```


