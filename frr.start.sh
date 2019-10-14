#!/bin/bash

docker run -d -it --net=host --name frr --privileged \
	-v ${PWD}/daemons:/etc/frr/daemons \
	-v ${PWD}/vtysh.conf:/etc/frr/vtysh.conf \
frrouting/frr
