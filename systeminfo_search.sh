#!/bin/bash

#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#    General Public License <gnu.org/licenses/gpl.html> for more details.
#
#    Nitin U. Yewale <nyewale@redhat.com>


# TODO

SYSTEMINFO_VERSION="0.1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -f $DIR/lib_systeminfo.sh ]; then
    DIR="/usr/share/systeminfo-$SYSTEMINFO_VERSION"
fi

source $DIR/lib_systeminfo.sh


_storage_arr=( powermt_dev_all infiniband_ibv_devices lsblk_scsi iscsi_tgtadm systool_scsi_disk powermt_display_paths \
	systool_scsi_host systool_scsi_tape lsblk devicemapper_status powermt_display lsscsi powermt_dump iscsi_session \
	infiniband_ibstatus nvme_id-ctrl= iscsi_nodes lvm_pvs_vgs_lvs blockdev lvm_pvs systool_qla2xxx powermt_display_options \
	 nvme_get-ns-id= lvm_lvdisplay targetcli_target_service multipath_ll lvm_pvscan targetcli_ls nvme_list iscsi_nodes_op \
	 lvm_pvdisplay ls_sys_block lsblk_t lvm_vgs systool_fc_remote_ports lvm_lvscan lvm_lvs parted-l devicemapper_info blkid \
	 collect_lvmdump systool_fchost lvm_vgscan iscsi_iface infiniband_ibv_devinfo devicemapper_table systool_scsi \
	 powermt_check_registration nvme_list_subsys nvme_show-regs= ls_dev targetcli_status powermt_display_ports \
	 lvm_vgdisplay systool_fc_transport scsi_id= fcoeadm_i sg_map lsblk_D infiniband_ibstat fcoeadm_f )

for i in "${arr[@]}"
do
	rc=`systeminfo -d storage -o $i`
	if [ "$rc" -ne "0" ]; then
		echo -e "\"systeminfo -d storage $i \" ${c[Red]}FAILED${c[NC]} \n"
	else
		echo -e " \"systeminfo -d storage $i\" ${c[Green]}SUCCESS${c[NC]} \n"
	fi
 done


_clusterha_arr=( "pcs" "pcs_status" "cman_tool" )

_filesystem_arr=( "ext4" "ext3" "xfs" )

opts=${_storage_arr[@]}
if grep -q "$1" <<< "$opts"; then
	echo -e "\n Hint : systeminfo -d storage -h \n"
	let a=1
fi

opts=${_clusterha_arr[@]}
if grep -q "$1" <<< "$opts"; then
	echo -e "\n Hint : systeminfo -d clusterha -h \n"
	let a=1
fi

opts=${_filesystem_arr[@]}
if grep -q "$1" <<< "$opts"; then
	echo -e "\n Hint : systeminfo -d filesystem -h \n"
	let a=1
fi

if [[ $a -lt "1" ]] ; then
	echo -e "\n *** Help for \"$1\" not found. *** \n"
fi
