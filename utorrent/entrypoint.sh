#!/bin/bash

function info {
	echo "[ INFO  ]  $1"
}

function error {
	echo "[ ERROR ]  $1"
}

function get_process {
	echo $(echo `ps aux | grep "/utorrent/utserver -settingspath"`)
}

info "Starting utorrent..."
/utorrent/utserver -settingspath /utorrent/settings -configfile /utorrent/settings.conf -logfile /utorrent/utserver.log &
tail -f /utorrent/utserver.log > /dev/stderr &

while [[ $(get_process) != "" ]]; do
	sleep 1
done

echo ""
error "utorrent down, exiting container"
exit 1
