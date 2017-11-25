#!/bin/env nash

hugo
git add blog
git commit -a -m "publishing site"
git push origin
