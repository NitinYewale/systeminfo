# bash completion for systeminfo
#
# Copyright (c) 2020 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA. 
#
# Author : Nitin U. Yewale <nyewale@redhat.com>
#
### declare arrays

_storage_arr=( powermt_dev_all infiniband_ibv_devices lsblk_scsi iscsi_tgtadm systool_scsi_disk powermt_display_paths systool_scsi_host systool_scsi_tape lsblk devicemapper_status powermt_display lsscsi powermt_dump iscsi_session infiniband_ibstatus nvme_id-ctrl= iscsi_nodes lvm_pvs_vgs_lvs blockdev lvm_pvs systool_qla2xxx powermt_display_options nvme_get-ns-id= lvm_lvdisplay targetcli_target_service multipath_ll lvm_pvscan targetcli_ls nvme_list iscsi_nodes_op lvm_pvdisplay ls_sys_block lsblk_t lvm_vgs systool_fc_remote_ports lvm_lvscan lvm_lvs parted-l devicemapper_info blkid lvmdump systool_fchost lvm_vgscan iscsi_iface infiniband_ibv_devinfo devicemapper_table systool_scsi powermt_check_registration nvme_list_subsys nvme_show-regs= ls_dev targetcli_status powermt_display_ports lvm_vgdisplay systool_fc_transport scsi_id= fcoeadm_i sg_map lsblk_D infiniband_ibstat fcoeadm_f )

_clusterha_arr=( pcs pcs_status cman_tool )

_filesystem_arr=( ext4 ext3 xfs )

_kernel_arr=( lsmod sysctl_a list_slab )

 _domain_options()
{
	local opts
	_init_completion || return
	case "$1" in 
		storage)
		opts=${_storage_arr[@]}
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		;;
		clusterha)
		opts=${_clusterha_arr[@]}
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		;;
		filesystem)
		opts=${_filesystem_arr[@]}
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		;;
		kernel)
		opts=${_kernel_arr[@]}
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
	esac
}


_systeminfo()
{
    local opts cur prev prev2
    _init_completion || return
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    prev2="${COMP_WORDS[COMP_CWORD-2]}"

	if [[ ${prev} == systeminfo ]] ; then
		opts="-h -d -v"
        	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        	return 0
	elif 
		[[ ${prev} == -d ]] ; then
		opts="clusterha filesystem storage"
            	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) ) 
		return 0	
	else
		case "${prev}" in
		storage | clusterha | filesystem) 
			opts="-o -c -h"
			COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
			;;
		-o)	
			_domain_options $prev2
			return 0
			;;
		-c)	
			_domain_options $prev2
			return 0
			;;
		esac
	fi

} &&

complete -F _systeminfo systeminfo
