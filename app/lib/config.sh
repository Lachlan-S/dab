#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh

config_get() {
	path="$DAB_CONF_PATH/$1"
	[ ! -r "$path" ] || cat "$path"
}

config_set() {
	key="$1"
	shift

	path="$DAB_CONF_PATH/$key"
	if [ -n "${1:-}" ]; then
		[ "$(carelessly cat "$path")" = "$*" ] && return 0
		whisper "setting config key $key to $*"
		mkdir -p "$(dirname "$path")"
		echo "$@" >"$path"
	elif [ -f "$path" ]; then
		whisper "deleting config key $key"
		rm -f "$path"
	fi
}

config_chmod() {
	key="$1"
	mode="$2"
	chmod "$mode" "$DAB_CONF_PATH/$key"
	whisper "change $key mode to $mode"
}

config_add() {
	key="$1"
	shift

	[ -n "$1" ] || fatality "must provide some value to add"

	path="$DAB_CONF_PATH/$key"
	silently grep -E "^$*$" "$path" && return 0
	mkdir -p "$(dirname "$path")"
	echo "$@" >>"$path"
	whisper "added $* to config key $key which now contains $(wc -l <"$path") value(s)"
}