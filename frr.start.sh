#!/bin/bash

# enable kernel settings
cp -f 90-frr-settings.conf /etc/sysctl.d/
sysctl --system
#p /etc/sysctl.d/90-frr-settings.conf

# start frr container
docker run -d -it --net=host --name frr --privileged \
	-v ${PWD}/frr:/etc/frr \
frrouting/frr
