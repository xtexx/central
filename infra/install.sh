#!/usr/bin/env bash

git clone \
	--depth 1 \
	--recurse-submodules \
	--shallow-submodules \
	https://codeberg.org/xtex/infra.git infra

ln -s infra/infra.sh ~/.infra
