#!/bin/bash

set -e

: ${FORGEJO:=/tmp/forgejo}

function dependencies() {
    if ! which jq curl > /dev/null ; then
	apt-get -qq update
	apt-get -q install -q jq curl
    fi
}

function latest() {
    local major="$1"

    if test "$major" = "next" ; then
	curl -sS https://codeberg.org/api/v1/repos/forgejo/forgejo/releases | jq -r '.[] | .tag_name' | sort -r | head -1
    else
	curl -sS https://codeberg.org/api/v1/repos/forgejo/forgejo/releases | jq -r '.[] | .tag_name | select(startswith("'$major'"))' | sort -r | head -1
    fi
}

function download() {
    if test -f /tmp/forgejo ; then
	return
    fi
    local version=$(latest)
    curl -sS "https://codeberg.org/forgejo/forgejo/releases/download/${version}/forgejo-${version#v}-linux-amd64" > ${FORGEJO}
    chmod +x ${FORGEJO}
}

function front() {
    # Add the frontmatter and a note at the top of the file
    cat <<'EOF'
---
title: Forgejo CLI
license: 'CC-BY-SA-4.0'
---

<!--
This page should not be edited manually.
To update this page, run the following command from the root of the docs repo:
```
./scripts/cli-docs.sh > ./docs/admin/command-line.md
```
-->
EOF
}

function section() {
    local depth="$1"
    local cmd="$2"
    local title="${3:-$cmd}"

    echo
    echo "${depth} ${title}"
    echo
    echo '```'
    ${FORGEJO} $cmd --help
    echo '```'
}

function generate() {
    front

    section "##" "" 'forgejo `--help`'

    section "##" "forgejo-cli"

    section "###" "forgejo-cli actions"
    section "###" "forgejo-cli actions generate-runner-token"
    section "###" "forgejo-cli actions generate-secret"
    section "###" "forgejo-cli actions register"

    section "##" "web"

    section "##" "dump"

    section "##" "admin"

    section "###" "admin user"
    section "###" "admin user create"
    section "###" "admin user list"
    section "###" "admin user change-password"
    section "###" "admin user delete"
    section "###" "admin user generate-access-token"
    section "###" "admin user must-change-password"

    section "###" "admin repo-sync-releases"

    section "###" "admin regenerate"

    section "###" "admin auth"
    section "###" "admin auth add-oauth"
    section "###" "admin auth update-oauth"
    section "###" "admin auth add-ldap"
    section "###" "admin auth update-ldap"
    section "###" "admin auth add-ldap-simple"
    section "###" "admin auth update-ldap-simple"
    section "###" "admin auth add-smtp"
    section "###" "admin auth update-smtp"
    section "###" "admin auth list"
    section "###" "admin auth delete"

    section "###" "admin sendmail"

    section "##" "migrate"

    section "##" "keys"

    section "##" "doctor"
    section "###" "doctor check"
    section "###" "doctor recreate-table"
    section "###" "doctor convert"

    section "##" "manager"
    section "###" "manager shutdown"
    section "###" "manager restart"
    section "###" "manager reload-templates"
    section "###" "manager flush-queues"
    section "###" "manager logging"
    section "###" "manager logging pause"
    section "###" "manager logging resume"
    section "###" "manager logging release-and-reopen"
    section "###" "manager logging remove"
    section "###" "manager logging add"
    section "###" "manager logging add file"
    section "###" "manager logging add conn"
    section "###" "manager logging log-sql"
    section "###" "manager processes"

    section "##" "embedded"
    section "###" "embedded list"
    section "###" "embedded view"
    section "###" "embedded extract"

    section "##" "migrate-storage"

    section "##" "dump-repo"

    section "##" "restore-repo"

    section "##" "cert"

    section "##" "generate secret"
}

function cleanup() {
    sed \
	-e 's/forgejo-dump-.*.zip/forgejo-dump-<timestamp>.zip/' \
	-e '/^ *actions *$/d'
}

function run() {
    local version="$1"

    dependencies
    download $version
    generate | cleanup
}

"${@:-run}"
