package main

import (
	caddycmd "github.com/caddyserver/caddy/v2/cmd"

	_ "github.com/aksdb/caddy-cgi/v2"
	_ "github.com/caddyserver/caddy/v2/modules/standard"
	_ "github.com/caddyserver/replace-response"
	_ "github.com/hairyhenderson/caddy-teapot-module"
)

func main() {
	caddycmd.Main()
}
