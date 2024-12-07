#!/usr/bin/env bash

tiang::target psf ssh://p.projectsegfau.lt
tiang::target envs ssh://envs.net
tiang::target vern ssh://vern.cc
tiang::target tfdev ssh://dev.toolforge.org
tiang::target koit ssh://koit.local

tiang::defineCommand infra::customCommands
tiangCommandsUsage+="""
    -infra --infra  [COMMAND]   Run a infra command
"""
infra::customCommands() {
	if [[ "$1" == "-infra" || "$1" == "--infra" ]]; then
		[ $# -lt 2 ] && tiang::error "1 parameter is required for --infra"
		# shellcheck disable=SC2086
		tiang::runParallelOnTargets tiang::runSSH "./.infra" $2
		tiangHandledParams=2
	else
		tiangHandledParams=0
	fi
}
