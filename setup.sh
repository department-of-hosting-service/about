#!/bin/bash

# exit 0

dir="$(dirname "$0")"
log_path="$dir/log"
logfile="$log_path/setup.log"
hosts_db="$dir/hosts"

temp_mount="/mnt/target"

mac_addr=`cat /sys/class/net/eth0/address`

echo "Trying to reset machine with the MAC $mac_addr" >> "$logfile"
echo "This script has been called as $0" >> "$logfile"
echo "" >> "$logfile"

hostname=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f1)
if [ -z "$hostname" ]; then echo "Could not determine hostname for node. Exiting." >> "$logfile"; echo "" >> "$logfile"; exit 0; fi;
image_file=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f3)
net_ip_addr=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f4)
net_netmask=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f5)
net_gateway=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f6)
net_broadcast=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f7)
net_nameserver=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f8)
target_device=$(cat "$hosts_db" | grep "$mac_addr" | tr -s ' ' | cut -d" " -f9)

echo "Resetting host $hostname, $mac_addr" >> "$logfile"
echo "" >> "$logfile"

## New host-specific logfile
logfile="$log_path/$hostname.log"
date > "$logfile"

cd "$dir"

## write image to disk ##########################################
echo "Writing image $image_file to $target_device..." >> "$logfile"
gzip -cd "$image_file" | pv -f -i 20 2>&1 >"$target_device" | stdbuf -oL tr '\r' '\n' >> "$logfile"
sync
echo "Done." >> "$logfile"
echo "" >> "$logfile"



## System konfigurieren
echo "Updating system configuration ..." >> "$logfile"

## Mount harddrive
mount -t ext4 "$target_device"1 "$temp_mount"

# updating ssh keys...
echo "## SSH fingerprints" >> "$logfile"
rm "$temp_mount"/etc/ssh/ssh_host_rsa_key
rm "$temp_mount"/etc/ssh/ssh_host_dsa_key
rm "$temp_mount"/etc/ssh/ssh_host_ecdsa_key
chroot "$temp_mount" /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
chroot "$temp_mount" /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
chroot "$temp_mount" /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
chroot "$temp_mount" /usr/bin/ssh-keygen -lf /etc/ssh/ssh_host_rsa_key >> "$logfile"
chroot "$temp_mount" /usr/bin/ssh-keygen -lf /etc/ssh/ssh_host_dsa_key >> "$logfile"
chroot "$temp_mount" /usr/bin/ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key >> "$logfile"

## setup network/interfaces #########################################
cat > "$temp_mount"/etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
#iface eth0 inet static
#       address $net_ip_addr
#       netmask $net_netmask
#       broadcast $net_broadcast
#       gateway $net_gateway

EOF


## setup hostname ##############################################
echo "## hostname" >> "$logfile"
echo "$hostname" > "$temp_mount"/etc/hostname

## setup hosts file ##############################################
echo "## hosts file" >> "$logfile"
cat > "$temp_mount"/etc/hosts << EOF
127.0.0.1       localhost
$net_ip_addr       $hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

## setup nameservers ##############################################
# TODO
# das muss vermutlich aktualisiert werden
cat > "$temp_mount"/etc/resolv.conf << EOF
nameserver 2001:4f8:0:2::14
nameserver 85.214.20.141
nameserver 194.150.168.168
nameserver 204.152.184.76
nameserver 213.73.91.35
EOF

## setting passwords ###############################################
echo "## Passwords" >> "$logfile"
pw=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-10};echo;`
echo "root:$pw" | chroot /"$temp_mount" /usr/sbin/chpasswd
echo "root:$pw" >> "$logfile"
pw=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-10};echo;`
echo "user:$pw" | chroot /"$temp_mount" /usr/sbin/chpasswd
echo "user:$pw" >> "$logfile"
echo "" >> "$logfile"

rm "$temp_mount"/etc/udev/rules.d/70-persistent-net.rules


## dhcp notifier ###############################################
echo "## IP notifier">> "$logfile"

cp "$dir"/ip-notifier/* "$temp_mount"/root
chmod 600 "$temp_mount"/root/notifier-key_rsa
cat > "$temp_mount"/root/update << EOF
#!/bin/bash
NODE_NAME="$hostname"

EOF
cat "$dir"/ip-notifier/update >> "$temp_mount"/root/update

#cp "$temp_mount"/etc/rc.local "$temp_mount"/etc/rc.local.bak
#echo "/root/update" > "$temp_mount"/etc/rc.local
#echo "exit 0" >> "$temp_mount"/etc/rc.local

cat > "$temp_mount/etc/systemd/system/update.service" << EOF
[Unit]
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/bin/bash /root/update -x
ExecStart=/bin/rm /etc/systemd/system/update.service
ExecStart=/bin/systemctl daemon-reload
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

chroot "$temp_mount" /bin/ln -s "/etc/systemd/system/update.service" "/etc/systemd/system/multi-user.target.wants/update.service"

umount "$temp_mount"

