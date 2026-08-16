version := 'git~' + shell("git describe --long --always | tr -d '\\n'")

default: build push deploy

build-caddy ARCH:
	GOOS=linux GOARCH={{ARCH}} go build \
		-o caddy-{{ARCH}} \
		-ldflags '-w -s' \
		-trimpath \
		-tags 'nobadger,nomysql,nopgx'

[parallel]
build: (build-caddy 'amd64') (build-caddy 'loong64')
	podman manifest rm -i codeberg.org/xtex/home
	podman buildx build \
		--force-rm \
		--squash \
		--build-arg "VERSION={{version}}" \
		--platform linux/amd64,linux/loong64 \
		--jobs 2 \
		--manifest codeberg.org/xtex/home \
		.

push:
	podman manifest push codeberg.org/xtex/home

deploy:
	ssh cotton.s.xvnet0.eu.org -- '\
		podman pull codeberg.org/xtex/home; \
		systemctl --user restart xtex-home; \
	'
