#!/bin/bash

found=false
ranConfig=false
resyncRequired=false

function info {
	echo "[ INFO  ]  $1"
}

function error {
	echo " [ ERROR ]  $1"
}

function init_config {
	ranConfig=true
	if [ ! -f "$1/config" ]; then
		info "no config file found for $1, initializing with default config"
		cp /default-config "$1/config"
		defaultDir="sync_dir = \"$1\""
		echo ${defaultDir/"/config/"/"/data/"} >> "$1/config"
	fi

	echo ""
	/onedrive --confdir="$1"
}

function start_monitor {
	info "starting background process for $1"
	/onedrive --monitor --confdir="$1" &
}

function start_process {
	if [ ! -f "$1/.sync_list.sha" ] && [ ! -f "$1/sync_list" ]; then
		start_monitor $1
		return
	fi
	if [ -f "$1/.sync_list.sha" ] && [ -f "$1/sync_list" ]; then
		old=$(cat "$1/.sync_list.sha")
		new=$(shasum -a 256 "$1/sync_list")

		if [ $old == $new ]; then
			start_monitor $1
			return
		fi
	fi
	if [ -f "$1/sync_list" ]; then
		echo $(shasum -a 256 "$1/sync_list") >  "$1/.sync_list.sha"
	fi

	info "detected a new version of '$1/sync_list', resync required, starting..."
	/onedrive --resync --confdir="$1"
	start_monitor $1
}

function get_process {
	echo $(echo `ps aux | grep onedrive` | grep "monitor")
}

for dir in /config/*/
do
	dir="${dir%*/}"
	if [ -d "${dir}" ]; then
		found=true
		if [ ! -f "${dir}/config" ] || [ ! -f "${dir}/refresh_token" ] || [ ! -f "${dir}/items.sqlite3" ]; then
			init_config ${dir}
		else
			start_process ${dir}
		fi
	fi
done

if [ $found == "false" ]; then
	error "no config volumes were mounted, unable to start"
	exit 1
fi

if [ $ranConfig == "true" ]; then
	info "client(s) initialized, container restart required."
	exit 0
fi

while [[ $(get_process) != "" ]]; do
	sleep 5
done

info "no monitors alive"
