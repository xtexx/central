#!/usr/bin/env sh

current_branch=$(git branch --show-current)
repo_path=$(pwd)

# Clone the website repo, or make sure the current clone is up to date
if [ ! -e "./.preview" ];then
	git clone https://codeberg.org/forgejo/website.git .preview
	cd .preview
else
	cd .preview
	git checkout main
	git pull
fi

# make sure the docs content of the website is up to date
git submodule update --remote

# install the website dependencies
pnpm install

# symlink the current docs branch from the website content repo
rm -rf ./src/content/docs/$current_branch
mkdir -p $(dirname ./src/content/docs/$current_branch)  # in case of branch names with slashes
ln -s $repo_path/docs/ ./src/content/docs/$current_branch

rm -rf ./public/images/$current_branch
mkdir -p $(dirname ./src/content/images/$current_branch)  # in case of branch names with slashes
ln -s $repo_path/images/ ./public/images/$current_branch

# once the dev server is running, open the current docs branch in the browser
sleep 3 && open http://localhost:3000/docs/$current_branch/ &

# start the dev server
pnpm run dev
