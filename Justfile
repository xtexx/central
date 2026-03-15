deploy: build
    rsync -vrc --force --delete-after public/ cotton.s.xvnet0.eu.org:apps/blog
    rsync -vrc --force --delete-after public/ p.projectsegfau.lt:apps/blog

build:
    rm -rf public; hugo build --enableGitInfo --minify