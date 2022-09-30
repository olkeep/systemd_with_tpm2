#!/bin/bash


function prereqs()
{
	#sudo apt install libtss2-dev
	  #libtss2-dev libtss2-fapi1 libtss2-rc0 libtss2-tctildr0

	cat <<-EOF
	  1) You must have created /etc/crypttab
	    e.g.:  /dev/sda2 none tpm2-device=auto
	    tip: can use blkid to get the UUID of the device too.

	  2) You must have installed necessary TSS2 libraries
	    e.g. sudo apt install libtss2-dev
	EOF

	read -p "Enter to continue"
}

function install_crypt_setup_mod_scripts()
{
	#apply patches:
	mkdir -p patched
	pushd patched >& /dev/null

	cp /usr/lib/cryptsetup/functions cryptsetup_functions
	cp /usr/share/initramfs-tools/scripts/local-top/cryptroot cryptroot

	patch cryptsetup_functions ../patches/cryptsetup_functions.patch
	patch cryptroot ../patches/cryptroot.patch

	cp cryptsetup_functions /usr/lib/cryptsetup/functions
	cp cryptroot /usr/share/initramfs-tools/scripts/local-top/cryptroot

	popd >& /dev/null

	#install the initramfs hook to include the required program and libtss2 in the initramfs
	cp scripts/systemd_cryptsetup_hook /etc/initramfs-tools/hooks
}

function update_initramfs()
{
	update-initramfs -u -k "$(uname -r)"
}

function tldr_just_work()
{
	prereqs && \
	install_crypt_setup_mod_scripts && \
	update_initramfs && \
	echo SystemD with TPM2 installation complete.
}


if [[ "${EUID}" -ne 0 ]] ; then
	echo "This script must be run as root.  Try:
		sudo $0
		"
	exit 1
fi

tldr_just_work
