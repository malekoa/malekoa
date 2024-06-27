#!/bin/bash

# Set your repository variables
REPO="https://github.com/malekoa/malekoa.github.io.git"
BRANCH="main" # or "master"

# Build the Hugo site
hugo

# Go to the public directory
cd public

# Initialize a new git repository and push the files
git init
git add .
git commit -m "Deploying site"
git remote add origin $REPO
git push -f origin $BRANCH

# Go back to the root directory
cd ..

# Remove the public directory
rm -rf public