ifndef VERBOSE
MAKEFLAGS += --no-print-directory
endif

CONTAINERIMAGENAME:=frrouting/frr
CONTAINERIMAGEVERSION:=latest
SERVICENAME:=frr
TEMPLATESERVICEFILENAME:=frr.service_template
TEMPLATESTARTILENAME:=frr.start.sh_template
TEMPLATESTOPFILENAME:=frr.stop.sh_template
SCRIPTDESTDIR:=/opt/frr
SERVICEFILEPATH=/etc/systemd/system
SERVICEFILENAME:=frr.service
STARTILENAME:=frr.start.sh
STOPFILENAME:=frr.stop.sh
SHELLPATH:=/bin/bash
DAEMONFILEPATH:=$(SCRIPTDESTDIR)/frr

.PHONY: install
install:
	$(MAKE) check_root
	$(MAKE) create_service_file
	$(MAKE) create_service_stop_file
	$(MAKE) create_service_start_file
	$(MAKE) move_service_scripts
	$(MAKE) copy_frr_config_files
	$(MAKE) pull_frr_image
	@systemctl daemon-reload
	@systemctl enable "$(SERVICEFILENAME)"

check_root:
	@runner=`whoami` ; \
	if test $$runner != "root" ; \
	then \
			echo "You are not root. Please run as root"; \
			exit 1; \
	fi

create_service_file:
	@cp -f $(TEMPLATESERVICEFILENAME) $(SERVICEFILENAME)
	@sed -i 's|{{scriptPath}}|$(SCRIPTDESTDIR)|g' $(SERVICEFILENAME)
	@sed -i 's|{{shellPath}}|$(SHELLPATH)|g' $(SERVICEFILENAME)
create_service_start_file:
	@cp -f $(TEMPLATESTARTILENAME) $(STARTILENAME)
	@sed -i 's|{{serviceName}}|"$(SERVICENAME)"|g' $(STARTILENAME)
	@sed -i 's|{{containerImage}}|"$(CONTAINERIMAGENAME):$(CONTAINERIMAGEVERSION)"|g' $(STARTILENAME)
	@sed -i 's|{{daemonFilePath}}| $(DAEMONFILEPATH)|g' $(STARTILENAME)

create_service_stop_file:
	@cp -f $(TEMPLATESTOPFILENAME) $(STOPFILENAME)
	@sed -i 's|{{serviceName}}|"$(SERVICENAME)"|g' $(STOPFILENAME)
	@sed -i 's|{{containerImage}}|"$(CONTAINERIMAGENAME):$(CONTAINERIMAGEVERSION)"|g' $(STOPFILENAME)

move_service_scripts:
	@mkdir -p "$(SCRIPTDESTDIR)"
	@mv -v $(STARTILENAME) "$(SCRIPTDESTDIR)"/
	@mv -v $(STOPFILENAME) "$(SCRIPTDESTDIR)"/
	@mv -v "$(SERVICEFILENAME)" "$(SERVICEFILEPATH)"/"$(SERVICEFILENAME)"

pull_frr_image:
	docker pull "$(CONTAINERIMAGENAME)":"$(CONTAINERIMAGEVERSION)"

configure_local_ip_forwarding:
	@cp -f 90-frr-settings.conf /etc/sysctl.d/
	@sysctl --system

copy_frr_config_files:
	@cp -R frr "$(SCRIPTDESTDIR)"