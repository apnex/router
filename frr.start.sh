#!/bin/bash
if [[ $(readlink -f $0) =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR="${BASH_REMATCH[1]}"
	CALLED="${BASH_REMATCH[2]}"
fi

# parameters
SERVICENAME="frr"
IMAGENAME="frrouting/frr"

# remove old instance
docker rm -v $(docker ps -qa -f name="${SERVICENAME}" -f status=exited) 2>/dev/null

# pre-requisites
# enable kernel settings
cp -f ${WORKDIR}/90-frr-settings.conf /etc/sysctl.d/
sysctl --system

# check if running
RUNNING=$(docker ps -q -f name="${SERVICENAME}")
if [[ -z "$RUNNING" ]]; then
	printf "[${SERVICENAME}] not running - now starting\n" 1>&2
	DOCKERRUN="docker run"
	if [[ $0 =~ ^[.] ]]; then # if local
		DOCKERRUN+=" -d"
	fi
	${DOCKERRUN} --net=host --privileged \
		-v ${WORKDIR}/frr:/etc/frr \
		--name "${SERVICENAME}" \
	"${IMAGENAME}"
fi
