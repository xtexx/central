deploy: build
    rsync -vrc --force --delete-after public/ cotton.s.xvnet0.eu.org:apps/blog

build:
    rm -rf public; hugo build --enableGitInfo --minify