#!/bin/bash

a=$(date +%A%d%B)

git add .
git commit -m $a
# git push origin main
git push -u origin master