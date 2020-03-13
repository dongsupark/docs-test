#!/bin/bash

set -euo pipefail

sudo apt-get install -y python3-venv mkdocs

git config --global user.name 'Flatcar Buildbot'
git config --global user.email 'buildbot@flatcar-linux.org'

# ssh key to clone flatcar-website-docs
eval "$(ssh-agent -s)"
ssh-add - <<< "${FLATCAR_WEBSITE_DOCS_GITHUB_ACTIONS_KEY}"
git clone git@github.com:kinvolk/flatcar-website-docs

# Clone flatcar-website-docs, build the docs, and copy the results under
# `site` directory into docs.flatcar-linux.org repo.
pushd flatcar-website-docs || exit

make fetch-docs
python3 -m venv .
source bin/activate
pip install -r requirements.txt
sudo gem install bundler && bundle
make build
rsync --exclude .git -av site/ ..

popd || exit

rm -rf flatcar-website-docs
