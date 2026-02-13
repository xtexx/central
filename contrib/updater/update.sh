#!/usr/bin/env bash

set -e
apk add curl jq git yq coreutils git-subtree jo \
	php{,-calendar,-ctype,-dom,-fileinfo,-iconv,-intl,-xml,-mbstring,-xmlreader} \
	composer npm

git config --global user.name "xvbot-mwupdater"
git config --global user.email "xvbot+codeberg@xvnet.eu.org"

function doUpdate() {
	git remote set-url origin "https://xvbot:$CODEBERG_TOKEN@codeberg.org/xens/mediawiki.git"

	git switch -c bot/update
	scripts/update
	if [[ "$(git rev-parse HEAD)" != "$(git rev-parse main)" ]]; then
		git push --force origin HEAD:refs/for/main \
			-o topic="bot/update" \
			-o force-push=true \
			-o title="[bot] Merge upstream" \
			-o description=""
	fi
	git switch main

	git switch -c bot/update
	scripts/updatetweaks
	if [[ "$(git rev-parse HEAD)" != "$(git rev-parse main)" ]]; then
		git push --force origin HEAD:refs/for/main \
			-o topic="bot/update-tweaks" \
			-o force-push=true \
			-o title="[bot] Update dependencies of XensTweaks" \
			-o description=""
	fi
	git switch main
}

if doUpdate; then
	curl \
		-H "Authorization: Bearer $NTFY_TOKEN" \
		-H "X-Title: MediaWiki auto-update succeeded" \
		-H "X-Tags: mediawiki,mwupdater,pipeline-success" \
		-H "X-Priority: min" \
		-d "$(printf 'MW-Updater-Status: success\nMW-Updater-HEAD: %s' "$(git rev-parse HEAD)")" \
		-SL --retry 2 \
		https://ntfy.xvnet.eu.org/publogs

	# close warning issues
	curl -X 'GET' \
		'https://codeberg.org/api/v1/repos/xens/atremis/issues?state=open&labels=bot%2Fupdate-fail&type=issues&limit=1' \
		-H 'Accept: application/json' |
		jq -r '.[] | .url' |
		while read -r issue; do
			curl -X 'PATCH' \
				"$issue" \
				-H 'Accept: application/json' \
				-H 'Content-Type: application/json' \
				-H "Authorization: token $CODEBERG_TOKEN" \
				-SL --retry 2 \
				-d "$(jo -- state=close)"
		done
else
	curl \
		-H "Authorization: Bearer $NTFY_TOKEN" \
		-H "X-Title: MediaWiki auto-update failed" \
		-H "X-Tags: mediawiki,mwupdater,pipeline-failure" \
		-H "X-Priority: min" \
		-d "MW-Updater-Status: failure" \
		-SL --retry 2 \
		https://ntfy.xvnet.eu.org/publogs

	# create a warning issue
	issues="$(curl -X 'GET' \
		'https://codeberg.org/api/v1/repos/xens/atremis/issues?state=open&labels=bot%2Fupdate-fail&type=issues&limit=1' \
		-H 'Accept: application/json' \
		-SL --retry 2 |
		jq '. | length')"
	if [[ "$issues" == "0" ]]; then
		curl -X 'POST' \
			'https://codeberg.org/api/v1/repos/xens/atremis/issues' \
			-H 'Accept: application/json' \
			-H 'Content-Type: application/json' \
			-H "Authorization: token $CODEBERG_TOKEN" \
			-SL --retry 2 \
			-d "$(jo title="[bot] MW Auto-updater fails" \
				body="" \
				labels="$(jo -a -- -n 239885)" assignees="$(jo -a -- -s xtex)")"
	fi
fi
