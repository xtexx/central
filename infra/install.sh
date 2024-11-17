#!/usr/bin/env bash
# Usage: curl -sSL 'https://codeberg.org/xtex/infra/raw/branch/main/infra/install.sh' | bash -
set -euxo pipefail

git clone \
	--depth 1 \
	--recurse-submodules \
	--shallow-submodules \
	https://codeberg.org/xtex/infra.git infra

ln -s infra/infra.sh ~/.infra
