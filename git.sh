#!/bin/sh

git add .
MSG=$(date+%s)
git commit -m "Updated $MSG"
git push
