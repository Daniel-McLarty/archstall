#Set up rest of script
	chmod +x archstall.sh archstallnvme.sh chrootsetup.sh chrootsetupnvme.sh yaysetup.sh

#Select Disk Type
	read -p "What type of disk do you use SATA or NVME? " type
		case $type in
			SATA ) echo ok;
				./archstall.sh;
				break;;
			NVME ) echo ok;
				./archstallnvme.sh
				break;;
			* ) echo please select SATA or NVME;;
		esac
	echo "Have a good day"
