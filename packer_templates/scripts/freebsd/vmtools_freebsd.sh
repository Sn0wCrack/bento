#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
  # There are no vbox-guest additions for freebsd arm64
  ARCH=$(uname -m)
  if [ "$ARCH" = "arm64" ]; then
    return
  fi

  # Disable X11 because vagrants are (usually) headless
  echo 'WITHOUT_X11="YES"' >> /etc/make.conf;

  pkg install -y virtualbox-ose-additions-nox11;

  echo 'vboxdrv_load="YES"' >>/boot/loader.conf;
  echo 'vboxnet_enable="YES"' >>/etc/rc.conf;
  echo 'vboxguest_enable="YES"' >>/etc/rc.conf;
  echo 'vboxservice_enable="YES"' >>/etc/rc.conf;

  echo 'virtio_blk_load="YES"' >>/boot/loader.conf;
  echo 'virtio_scsi_load="YES"' >>/boot/loader.conf;
  echo 'virtio_balloon_load="YES"' >>/boot/loader.conf;
  echo 'if_vtnet_load="YES"' >>/boot/loader.conf;

  echo 'ifconfig_vtnet0_name="em0"' >>/etc/rc.conf;
  echo 'ifconfig_vtnet1_name="em1"' >>/etc/rc.conf;
  echo 'ifconfig_vtnet2_name="em2"' >>/etc/rc.conf;
  echo 'ifconfig_vtnet3_name="em3"' >>/etc/rc.conf;

  pw groupadd vboxusers;
  pw groupmod vboxusers -m vagrant;
  ;;

vmware-iso|vmware-vmx)
  pkg install -y open-vm-tools-nox11;

  # for shared folder
  echo 'fuse_load="YES"' >>/boot/loader.conf;

  echo 'ifconfig_vmx0="dhcp"' >>/etc/rc.conf;
  ;;

parallels-iso|parallels-pvm)
  pkg install -y parallels-tools
  ;;

*)
  echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
  echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
  ;;

esac
