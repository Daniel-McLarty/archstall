#bash

	echo "Starting Install"
#Confirm start
	read -p "Do you want to install Arch GNU+Linux? (y/N) " yn

	case $yn in
		[yY] ) echo ok, Installing;
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo exiting;
			exit;;
	esac 

#Install start
	echo "Sit back and enjoy the show!"

	timedatectl set-ntp true

#disk setup
	selectdisk(){
		lsblk
		read -p "Example sda: " vardisk	
	}

#Partitioning Disk 	
	diskpart(){

		echo "Selct the disk you want to install Arch GNU+Linux to"
		selectdisk
		echo "WARNING: ALL DATA ON THAT DISK WILL BE LOST!"
		read -p "Do you wish to continue (y/N) " pd

		case $pd in
			[yY] ) echo "Wiping Disk";
				break;;
			[nN] ) echo "Leaving Installer";
				exit;;
			* ) echo "Leaving Installer";
				exit;;
		esac

		fdisk /dev/$vardisk <<EEOF
		g
		n
		
		
		+200M
		t
		1
		n
		
		
		+300M
		n
		
		
		
		t
		3
		30
		w
EEOF
	}
	diskpart

#Formating Disk
	diskfom(){
		echo "Formating Disk"
		mkfs.fat -F32 /dev/${vardisk}1
		mkfs.ext4 /dev/${vardisk}2
		cryptsetup luksFormat /dev/${vardisk}3
		cryptsetup open --type luks /dev/${vardisk}3 lvm
		pvcreate --dataalignment 1m /dev/mapper/lvm
		vgcreate volgroup0 /dev/mapper/lvm
		lvcreate -l 100%FREE volgroup0 -n lv_root
		modprobe dm_mod
		vgscan
		vgchange -ay
		mkfs.ext4 /dev/volgroup0/lv_root
		mount /dev/volgroup0/lv_root /mnt
		mkdir /mnt/boot
		mount /dev/${vardisk}2 /mnt/boot
		mkdir /mnt/etc
		genfstab -U -p /mnt >> /mnt/etc/fstab
	}
	diskfom

#Install Base
	instbase(){
		echo "Installing Base"
		pacstrap -i --noconfirm /mnt base base-devel
		cp chrootsetup.sh /mnt/chrootsetup.sh
		cp yaysetup.sh /mnt/yaysetup.sh
		cp extradisk.sh /mnt/extradisk.sh
		cp extradisknvme.sh /mnt/extradisknvme.sh
		arch-chroot /mnt /chrootsetup.sh
		umount -a
		read -p "Do you want to reboot now (y/N) " rb
			case $rb in
				[yY] ) echo rebooting;
					reboot now;
					break;;
				[nN] ) echo ok;
					break;;
				* ) echo ok;
						break;;
			esac
	}
	instbase
