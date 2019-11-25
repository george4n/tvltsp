#!/bin/bash

echo "Message:"
read MESSAGE

git pull
git add .
git commit -a -m "$MESSAGE"
git push
