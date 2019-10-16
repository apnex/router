#!/bin/bash
if [[ $(readlink -f $0) =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR="${BASH_REMATCH[1]}"
	CALLED="${BASH_REMATCH[2]}"
fi

# enable kernel settings
cp -f ${WORKDIR}/90-frr-settings.conf /etc/sysctl.d/
sysctl --system

# start frr container
if [[ $0 =~ ^[.] ]]; then
	docker run -d --net=host --privileged \
		--name frr \
		-v ${WORKDIR}/frr:/etc/frr \
	frrouting/frr
else
	docker run --net=host --privileged \
		--name frr \
		-v ${WORKDIR}/frr:/etc/frr \
	frrouting/frr
fi
