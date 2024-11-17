#!/usr/bin/env bash

tiang::target psf ssh://p.projectsegfau.lt
tiang::target exozyme ssh://exozy.me
tiang::target envs ssh://envs.net
tiang::target vern ssh://vern.cc
tiang::target tfdev ssh://dev.toolforge.org
tiang::target koit ssh://koit.local

tiang::defineCommand atremis::customCommands
tiangCommandsUsage+="""
    -ss --syncsec  [FILE]       Copy a secret file to targets
    -pull                       Run atremis pull
    -upd                        Run atremis update
"""
atremis::customCommands() {
	if [[ "$1" == "-infra" || "$1" == "--infra" ]]; then
		[ $# -lt 2 ] && tiang::error "1 parameter is required for --infra"
		# shellcheck disable=SC2086
		tiang::runParallelOnTargets tiang::runSSH "./.infra" $1
		tiangHandledParams=2
	else
		tiangHandledParams=0
	fi
}
