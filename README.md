
## Automatic Pull request Labeler

Automatically add labels to your pull requests.

### Action Options

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

assign_self: Assign the creator of the pull request as an assignee. ```[optional]```
```
assign-self: 'true' 
```

## A full example using this action:
```
name: "Automatic PR Labeler"
on:
  pull_request:
    types: [opened]
permissions: // Apply repository read and pull-request write permissions
  contents: read
  pull-requests: write
jobs:
  label:
    runs-on: ubuntu-latest
    env:
      GH_TOKEN: ${{ github.token }} // Needs github token
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 // Fetch the entire history of the repository
      - name: Assign labels
        uses: actions/automatic-labeler
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
          assign-self: 'true'
```


