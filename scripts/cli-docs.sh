#!/bin/bash

set -e

: ${FORGEJO:=/tmp/forgejo-binary}

function dependencies() {
    if ! which jq curl > /dev/null ; then
	apt-get -qq update
	apt-get -q install -q jq curl
    fi
}

function latest() {
    local major="$1"

    if test "$major" = "next" ; then
	select="" # this will pick whatever is the highest numbered release
    else
	select="$major"
    fi
    curl -sS https://codeberg.org/api/v1/repos/forgejo-experimental/forgejo/releases | jq -r '.[] | .tag_name | select(startswith("'$select'"))' | sort --reverse --version-sort | head -1
}

function download() {
    local major="$1"

    if test -f $FORGEJO ; then
	return
    fi
    local version=$(latest $major)
    curl -sS "https://codeberg.org/forgejo-experimental/forgejo/releases/download/${version}/forgejo-${version#v}-linux-amd64" > ${FORGEJO}
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

function section_help() {
    section "##" "" 'forgejo `--help`' | sed -e '/^VERSION:/d' -e '/built with GNU Make/d'
}

function generate() {
    front

    section_help

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
	-e '/^ *actions *$/d' \
	-e 's/ *$//'
}

function run() {
    local version="$1"

    dependencies >& /dev/null
    download $version
    generate | cleanup
}

"${@:-run}"
