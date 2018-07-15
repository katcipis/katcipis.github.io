#!/bin/env nash

hugo
git add blog categories tags
git commit -a -m "publishing site"
git push origin
