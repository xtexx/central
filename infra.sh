#!/usr/bin/env bash

infraDir=/home/xtex/infra

infra::log() {
	echo -e "\e[0;34m${FUNCNAME[1]}: $*\e[0m"
}

infra::error() {
	echo -e "\e[0;31m${FUNCNAME[1]}: $*\e[0m" 1>&2
	exit 1
}

infra::succ() {
	echo -e "\e[0;32m$*\e[0m"
}

infra::usage() {
	cat 1>&2 <<XXX
usage: $0 <COMMAND>

COMMAND:
    help                        Print usage
    pull                        Fetch changes from the infra repository
XXX
}

infra::main() {
	[ $# -eq 0 ] && infra::usage && exit
	local cmd=$1
	shift

	case $cmd in
	help | --help)
		infra::usage "$@"
		return
		;;
	pull)
		infra::pull "$@"
		return
		;;
	*)
		infra::error "unknown option: $cmd"
		;;
	esac
}

infra::pull() {
	git -C "$infraDir" fetch --depth 1 origin
	git -C "$infraDir" reset --hard origin/main
	git -C "$infraDir" submodule sync --recursive
	git -C "$infraDir" submodule update --init --recursive --recommend-shallow
	git -C "$infraDir" -c gc.reflogExpire=1 -c gc.reflogExpireUnreachable=0 \
		-c gc.rerereResolved=0 -c gc.rerereUnresolved=0 \
		-c gc.pruneExpire=now gc --quiet
}

infra::main "$@"
exit "$?"
