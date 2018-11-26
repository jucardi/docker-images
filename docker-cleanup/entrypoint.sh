#!/bin/bash

export SLEEP_TIMEOUT=${SLEEP_TIMEOUT:-86400}

while true
do
	docker system prune --all --force
	sleep ${SLEEP_TIMEOUT}
done