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
	podman buildx build \
		--force-rm \
		--squash \
		--build-arg "VERSION={{version}}" \
		--platform linux/amd64,linux/loong64 \
		--jobs 2 \
		--tag codeberg.org/xtex/home \
		.

push:
	podman image push codeberg.org/xtex/home

deploy:
	podman image scp codeberg.org/xtex/home cotton.s.xvnet0.eu.org::
	ssh cotton.s.xvnet0.eu.org -- '\
		systemctl --user restart xtex-home; \
	'
