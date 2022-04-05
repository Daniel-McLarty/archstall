#bash
setupdisk(){
	lsblk
	read -p "what disk: " diskan
	fdisk /dev/$diskan <<EEOF
	g
	n
	
	
	
	w
EEOF
	cryptsetup luksFormat /dev/${diskan}1
	read -p "what do you want your disk to be called: " sdname
	cryptsetup open --type luks /dev/${diskan}1 $sdnane
	mkfs.ext4 /dev/mapper/$sdname
	dd if=/dev/urandom of=/root/keyfile bs=1024 count=4
	chmod 0400 /root/keyfile
	sudo cryptsetup luksAddKey /dev/${diskan}1
	echo "$sdname /dev/${diskan}1 /root/keyfile luks" | tee -a /etc/crypttab
	mkdir /mnt/$sdnane;
	echo "/dev/mapper/$sdname /mnt/$sdmane ext4 defaults 0 2" | tee -a /etc/fstab
}
setupdisk

#Setup another disk
	read -p "do you want to setup another disk (y/N) " an
			case $an in
				[yY] ) echo ok;
					read -p "NVME or SATA" ns
						case $ns in
							SATA )
								setupdisk;
								break;;
							NVME )
								./extradisknvme.sh;
								break;;
						esac;
					break;;
				* ) echo ok;
					break;;
			esac
