# docker-cleanup

Simple docker image with the docker client installed which will periodically run `docker system prune --all --force`

This image is useful for cluster workers so it keeps the worker machines clean by removing older versions of containers when
they get deployed.

Need to mount the docker socket as a volume for it to manage the host machine.
