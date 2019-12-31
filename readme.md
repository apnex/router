# Building an FRR docker service on CentOS
## 1) create centos vm
**Warning**: Ensure you have created your CentOS VM with the following settings:  

Minimum Specifications:  
- vCPU: 2  
- MEM: 2 GB  
- DISK: 8 GB  

Also, you require a minimum of 3x Network Adapters for your router.

Or if you prefer, you can use the unattended PXE method.  

First, download the pre-made ISO from here:  
http://pxe.apnex.io/centos.iso

It is a tiny 1MB ISO - as it contains only iPXE code.  
All remaining OS files will be bootstrapped over the Internet via HTTP.  
Just mount this ISO to a CDROM of a VM and power on.  

VM Boot Order (must be **BIOS**):  
- 1: HDD  
- 2: CDROM

This is to ensure that after installation, the VM will boot normally.  
If CDROM is before HDD, the VM will be in an infinite loop restarting and rebuilding itself!

Further reading on the unattended method: https://github.com/apnex/pxe  

## 2) set nmcli profile for static IP
This is the "uplink" IP address on eth0 for the router to access the outside world  
This will disconnect any existing ssh sessions, log back into the new IP address after change
```
nmcli connection show eth0 | grep ipv4
nmcli connection edit eth0
set ipv4.method manual
set ipv4.addresses 172.16.101.140/24
set ipv4.gateway 172.16.101.1
set ipv4.routes 13.54.247.183/32 172.16.101.1 
set ipv4.dns 8.8.8.8
print ipv4
save
service network restart
```

## 3) set hostname
```
hostnamectl set-hostname router
```

## 4) install git
```
yum install -y git
```

## 5) install control-plane
```
cd ~/
git clone https://github.com/apnex/control-plane
```

## 6) clear existing iptables entries
Enable permissive iptables entries for packet forwarding
```
~/control-plane/iptables.flush.sh
```

## 7) install docker
```
~/control-plane/docker.install.sh
```

## 8) start and ensure docker enabled on-boot
```
systemctl start docker
systemctl enable docker
systemctl is-enabled docker
```

## 9) install frr
```
cd ~/
git clone https://github.com/apnex/router
cp ~/router/unit/frr.service /usr/lib/systemd/system/
```

## 10) enable frr
```
systemctl enable frr
systemctl start frr
systemctl status frr
docker images
docker ps
```

## 11) create admin user for router CLI
```
useradd admin
passwd admin
<enter password>
<repeat password>
usermod -aG docker admin
```

## 12) setup router CLI prompt for admin user
```
cp ~/router/frr.shell.sh /home/admin/
echo '/home/admin/frr.shell.sh; exit' >> /home/admin/.bashrc
chown -R admin:admin /home/admin
```

## 13) enable integrated vty config
```
su admin
write integrated <cr>
exit <cr>
```
