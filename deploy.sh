#!/bin/bash

# Build the project.
hugo

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source repos.
git push origin master

# deploy to tencentCloud
cd public
scp -r ./ root@118.24.78.115:/usr/share/nginx/html
cd ..
