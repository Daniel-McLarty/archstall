#Setup another disk
	read -p "do you want to setup another disk (y/N) " an
			case $an in
				[yY] ) echo ok;
					read -p "NVME or SATA" ns
						case $ns in
							SATA )
								./extradisk.sh;
								break;;
							NVME )
								./extradisknvme.sh;
								break;;
						esac;
					break;;
				* ) echo ok;
					break;;
			esac
#Chroot Install
        pacman -Suy linux-zen linux linux-headers linux-zen-headers nano openssh linux-firmware networkmanager wpa_supplicant wireless_tools netctl dialog lvm2 htop plasma dolphin konsole sddm git kate firefox packagekit-qt5 flatpak fwupd
	while true; do
		echo "ni: Nvidia GPU and Intel CPU"
		echo "na: Nvidia GPU and AMD CPU"
		echo "aa: AMD GPU and CPU"
		echo "ai: AMD GPU and Intel CPU"
		echo "ii: Intel GPU and CPU"
		echo "vb: virtualbox"
		read -p "Select System type from the list: " st
		
		case $st in
			ni ) pacman -S nvidia nvidia-dkms intel-ucode;
				break;;
			na ) pacman -S nvidia nvidia-dkms amd-ucode;
				break;;
			aa ) pacman -S mesa amd-ucode;
				break;;
			ai ) pacman -S mesa intel-ucode;
				break;;
			ii ) pacman -S mesa intel-ucode;
				break;;
			vb ) pacman -S virtualbox-guest-utils xf86-video-vmware;
				systemctl enable vboxservice;
				break;;
			* ) echo Invalid System Type 
		esac
	done
	systemctl enable sddm
	systemctl enable sshd
	systemctl enable NetworkManager
	sed -i.bak "s/block filesystems/block encrypt lvm2 filesystems/" /etc/mkinitcpio.conf
	mkinitcpio -p linux
	mkinitcpio -p linux-zen
	read -p "enter your locale example en_US.UTF-8: " locale
	localectl set-locale LANG=$locale
	locale-gen
	echo "Enter root password"
	passwd
	read -p "Enter your username: " un
	useradd -m -g users -G wheel $un
	echo "Enter account password"
	passwd $un
	echo " %wheel ALL=(ALL:ALL) ALL" >> etc/sudoers;
	pacman -S grub efibootmgr dosfstools os-prober mtools
	mkdir /boot/EFI
	read -p "What disk did you install ARCH GNU+Linux to? example sda: " disk
	mount /dev/${disk}1 /boot/EFI
	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
	read -p "What is your locale? example en: " le
	cp /usr/share/locale/$le\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/${le}.mo
	sed -i "s+loglevel=3 quiet+cryptdevice=/dev/${disk}3:volgroup0:allow-discards loglevel=3+" /etc/default/grub
	sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
	sed -i "s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/" /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	read -p "What do you want your hostname to be: " hn
	hostnamectl set-hostname $hn
	printf "127.0.0.1 localhost" >> /etc/hosts
	printf "127.0.1.1 $hn" >> /etc/hosts
	read -p "Enter swap size in MB: " ss
	dd if=dev/zero of=/swapfile bs=1M count=$ss status=progress
	chmod 600 /swapfile
	mkswap /swapfile
	cp /etc/fstab /etc/fstab.bak
	echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
	mount -a
	swapon -a
#optional setup	

	read -p "Do you want to install yay (y/N) " yn
		case $yn in
			[yY] ) echo installing yay;
				chmod 777 yaysetup.sh
				su $un -s ./yaysetup.sh
				break;;
			[nN] ) echo skiping;
				break;;
			*) echo skipping;
				break;;
		esac

	

	read -p "Do you want to install recomended packages (y/N) " rp
		case $rp in
			[yY] ) echo ok;
				pacman -S unrar rsync bash-completion traceroute bind cronie xdg-user-dirs ntfs-3g btrfs-progs exfat-utils gptfdisk fuse2 fuse3 fuseiso obs-studio kdenlive neofetch handbrake libreoffice pacman-contrib alsa-utils alsa-plugins pulseaudio pulseaudio-alsa celluloid qbittorrent lutris cups;
				break;;
			[nN] ) echo ok;
				break;;
			* ) echo ok;
				break;;
		esac

	echo "Done installing Arch GNU+Linux"
