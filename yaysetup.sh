#!/usr/bin/bash
    read -p "what is your username: " ur
    mkdir /home/$ur/git
	cd /home/$ur/git
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd ~
	yay -Sy p7zip-gui autofs vscodium
