#!/bin/sh

cd /home/ger/Proj/premia/fulgurigor.github.io
rm index.html
./R.R
git add --all
git commit -m "autocommit"
git push -u origin master