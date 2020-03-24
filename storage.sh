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
if ! [ -f $DIR/lib_systeminfo.sh ]; then
    DIR="/usr/share/systeminfo-$SYSTEMINFO_VERSION"
fi

source $DIR/lib_systeminfo.sh

###################### FUNCTIONS ######################
usage()
{

#echo -e "\n${c[Cyan]}To view the command"
#echo -e "\n${c[Yellow]}Usage : systeminfo -d storage${c[NC]} ${c[Cyan]}[-c option]${c[NC]}"

#echo -e "\n${c[Cyan]}To run the command"
#echo -e "${c[Yellow]}Usage : systeminfo -d storage${c[NC]} ${c[Cyan]}[-o option1,option2,..]${c[NC]}"

#echo -e "\n${c[Cyan]}[options]${c[NC]} \t ${c[Cyan]}- for domain storage${c[NC]}"
#echo "---------------------------"
#echo -e "\tcheck | config | lvm | lvm-check | lvm-config | device-mapper | nvme | ndctl | scsi | \
#scsi-check | scsi-config | block | vdo | vdo-check | FC | fcoe | infiniband |
#vdo-config | multipath | multipath-config | multipath-check | fcoe \n

echo -e "
device-mapper \t\tshow 'device-mapper_info' 'device-mapper_table' 'device_mapper_lstree'
devicemapper_info \tshow 'dmsetup info -c'
devicemapper_table \tshow 'dmsetup table'
devicemapper_lstree \tshow 'dmsetup ls --tree '

fcoeadm_i \t\tshow 'fcoeadm -i'
fcoeadm_f \t\tshow 'fcoeadm -f'

iscsi \t\t\tshow 'iscsi_nodes' 'iscsi_ifaces' 'iscsi_sessions'
iscsi_nodes \t\tshow iscsi_nodes
iscsi_ifaces \t\tshow interfaces accessing iscsi storage
iscsi_sessions \t\tshow available iscsi_sessions

lvm \t\t\tshow 'lvm_pvs' 'lvm_vgs' 'lvm_lvs'
lvm_pvs \t\tshow lvm Physical Volume Information
lvm_vgs \t\tshow lvm Volume Group Information
lvm_lvs \t\tshow lvm Logical Volume Information
lvm_help \t\tshow 'config_files' and 'useful commands' for changing lvm configuration

lsblk \t\t\tList block devices
lsblk_t \t\tList block devices topology
lsblk_D \t\tPrint information about the discarding capabilities
blkid \t\t\tPrint block device attributes
blockdev \t\tcall block device ioctls from the command line
ls_dev \t\t\tLisr /dev contents
ls_sys_block \t\tList /sys/block contents

multipath \t\tShow multipath devices

powermt_display \tshow 'powermt display'
powermt_dev_all \tshow 'powermt display dev=all'
powermt_check_registration \tshow 'powermt powermt check_registration'
powermt_display_options \tshow 'powermt display'
powermt_display_ports \tshow 'command powermt display ports'
powermt_display_paths \tshow 'powermt display paths'
powermt_dump \t\tshow 'powermt dump'

systool_fchost \t\tShow Fibre Channel Host details
systool_fc_remote_ports Show Fibre Channel Remote ports details
systool_fc_transport \tShow FC transport details
systool_qla2xxx \tShow qla2xx details
systool_scsi \t\tShow scsi details
systool_scsi_disk \tShow scsi disk details'
systool_scsi_host \tShow scsi host details
systool_scsi_tape \tShow tape details

targetcli_ls \t\tShow targetcli configuration
targetcli_status \tShow targetcli status
targetcli_target_service Show status of target.service
\n"

## Manual intervention needed here as of now. Need to figure out exporting this array to other files

## To get the list of options, comment the "COMMENT" lines and run "systeminfo -d storage -h".
## Copy the output to systeminfo_search.sh and to the bash completion script located at /etc/bash_completion.d

<<'COMMENT'
_KEYS=(${!_storage_command_dict[@]})
_storage_arr=${_KEYS[@]}
echo $_storage_arr
COMMENT

}

_storage()
{

local _is_disk _is_nvme _is_multipath _is_lvm _is_usb _is_pmem _is_raid _is_powermt

_is_disk="`lsblk -l | grep sd`"
_is_nvme="`lsblk -l |awk '{ print $1 }' |grep nvme`"
_is_multipath="`lsblk -l |grep mpath`"
_is_lvm="`lsblk -l |grep lvm`"
_is_usb="`lsblk --scsi |grep usb`"
_is_pmem="`grep pmem /proc/partitions`"
_is_raid="`lsblk -l|grep raid`"
_is_powermt=`command -v powermt |grep -qv alias >/dev/null 2>&1`

if [ "$_is_disk" ]; then
  echo -e "${c[Cyan]}Scsi Devices${c[NC]}"
  lsblk -l |head -n1
  lsblk -l | tail -n +2 | awk '{if ($6 == "disk") print}' | grep ^sd | grep -v usb |sort -k1 |uniq
  echo -e "\n"
else
  echo -e "${c[Orange]}No SCSI devices found.\n${c[NC]}"
fi

if [ "$_is_nvme" ]; then
  echo -e "${c[Cyan]}NVME Devices${c[NC]}"
  if _exists nvme && [ `id -u` = "0" ]; then
    nvme list
  else
    lsblk -l |head -n1
    lsblk -l | grep -v "MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT" | awk '{if ($6 == "disk") print}' |grep ^nvme |sort -k1 |uniq
  fi
  echo -e "\n"
else
  echo -e "${c[Orange]}No NVME devices found.\n${c[NC]}"
fi

if [ "$_is_lvm" ]; then
  echo -e "${c[Cyan]}LVM Devices${c[NC]}"
  lsblk -l |head -n1
  lsblk -l | grep -v "MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT" | awk '{if ($6 == "lvm") print}' |sort -k1 |uniq
  echo -e "\n"
else
  echo -e "${c[Orange]}No LVM devices found.\n${c[NC]}"
fi

# Commands that need root/sudo privileges, need to follow such syntax.

if [ "$_is_multipath" ]; then
  _executable=multipath
  if [ `id -u` -gt "0" ]; then
    prompt=$(sudo -nl multipath 2>&1)
    if [ $? -eq "1" ]; then
      echo -e "${c[Cyan]}Multipath Devices${c[NC]}"
      echo -e "\nroot/sudo privileges are needed to execute the \"$_executable\" command. \n"
    else
      echo -e "${Cyan}Multipath Devices${NC}"
      sudo multipath -ll |grep -B1 hwhandler |grep dm
    fi
  else
    echo -e "${c[Cyan]}Multipath Devices${c[NC]}"
    multipath -ll |grep -B1 hwhandler |grep dm
  fi
  echo -e "\n"
else
  echo -e "${c[Orange]}No MULTIPATH devices found.\n${c[NC]}"
fi

if [ "$_is_pmem" ]; then
  if _exists ndctl; then
    echo -e "${c[Cyan]}PMEM Devices${c[NC]}"
    ndctl list
  else
    lsblk -l |head -n1
    lsblk -l |grep pmem
  fi
  echo -e "\n"
else
  echo -e "${c[Orange]}No PMEM devices found.\n${c[NC]}"
fi

if [ "$_is_usb" ]; then
  echo -e "${c[Cyan]}USB devices${c[NC]}"
  lsblk --scsi |head -n1
  lsblk --scsi |grep -e 'usb'
  echo -e "\n"
else
  echo -e "${c[Orange]}No USB devices found.\n${c[NC]}"
fi

if [ "$_is_raid" ]; then
  echo -e "${c[Cyan]}RAID DEVICES${c[NC]}"
  cat /proc/mdstat |grep md
  echo -e "\n"
else
  echo -e "${c[Orange]}No RAID devices found.\n${c[NC]}"
fi

if [ "$_is_powermt" ]; then
  powermt display |grep "Pseudo name"
else
  echo -e "${c[Orange]}No Powerpath devices found.\n${c[NC]}"
fi


echo -e "${c[Cyan]}MountPoint and File system Usage${c[NC]}"
df -h |grep -v -e ^tmpfs -e ^devtmpfs
echo -e "\n"

exit 0

}

### These function are being called through KEYS

<<'COMMENT'
_command2()
{
  if _exists $1; then
    _executable=$1
    if [ `id -u` -gt "0" ]; then
      _need_sudo $_executable
      if [ ! "$_needsudo" ]; then
        _n1="0"
      else
        _n1="1"
      fi
    else
      _n1="2"
    fi
  else
    echo "Your system does not have "$_executable" command. "
  fi
}


_scsi_id()
{
  _executable=/lib/udev/scsi_id
  _command2 $_executable
  # $1 below is the arg supplied to _scsi_id
  case "$_n1" in
    0)
    echo -e "Command : /lib/udev/scsi_id --whitelisted --device=$1 \n"
    echo -e "Output : \n"
    # Actual command
    /lib/udev/scsi_id --whitelisted --device=$1
    echo -e "\n"
    ;;
    1)
    echo -e "Command : sudo /lib/udev/scsi_id --whitelisted --device=$1 \n"
    echo -e "Output : \n"
    # Actual command
    sudo /lib/udev/scsi_id --whitelisted --device=$1
    echo -e "\n"
    ;;
    2)
    echo -e "Command : /lib/udev/scsi_id --whitelisted --device=$1 \n"
    echo -e "Output : \n"
    # Actual command
    /lib/udev/scsi_id --whitelisted --device=$1
    echo -e "\n"
    ;;
  esac
  exit 0
}
COMMENT

_scsi_id()
{
  if _exists /lib/udev/scsi_id; then
    _executable=/lib/udev/scsi_id
    if [ `id -u` -gt "0" ]; then
      _need_sudo $_executable
      if [ ! "$_needsudo" ]; then
        echo -e "${c[Cyan]}Command :${c[NC]} /lib/udev/scsi_id --whitelisted --device=$1 \n"
        if [ ! "$_show_command" ]; then
          echo -e "${c[Yellow]}Output :${c[NC]} \n"
          # Actual command
          /lib/udev/scsi_id --whitelisted --device=$1
          echo -e "\n"
        else
          exit 0
        fi
      else
        echo -e "${c[Cyan]}Command :${c[NC]} sudo /lib/udev/scsi_id --whitelisted --device=$1 \n"
        if [ ! "$_show_command" ]; then
          echo -e "${c[Yellow]}Output :${c[NC]} \n"
          # Actual command
          sudo /lib/udev/scsi_id --whitelisted --device=$1
          echo -e "\n"
        else
          exit 0
        fi
      fi
    else
      echo -e "${c[Cyan]}Command :${c[NC]} /lib/udev/scsi_id --whitelisted --device=$1 \n"
      echo -e "${c[Yellow]}Output :${c[NC]} \n"
      # Actual command
      /lib/udev/scsi_id --whitelisted --device=$1
    fi
  else
    echo "Your system does not have "$_executable" command. "
  fi
}


_lvm_pvs_vgs_lvs()
{
 _command pvs -a -v -o +pv_mda_free,pv_mda_size,pv_mda_count,pv_mda_used_count
 _command vgs -v -o +vg_mda_count,vg_mda_free,vg_mda_size,vg_mda_used_count,vg_tags
 _command lvs -a -o +lv_tags,devices,lv_kernel_read_ahead,lv_read_ahead,stripes,stripesize
}



###################### /FUNCTIONS ######################  These function are being called through KEYS


# Declare a dictionary with the domain name to store the mapping of options to the actual commands
# If actual command could not be run directly, we could create a fuction. For example, see functions "_lvm_pvs_vgs_lvs" "_device-mapper_info"

declare -A _storage_command_dict

_storage_command_dict=(

# DeviceMapper
["devicemapper_table"]="_command dmsetup table"  #Run the command from _storage_command_dict
["devicemapper_info"]="_command dmsetup info -c"  #Redirect to particular function. Ensure that function is present
["devicemapper_status"]="dmsetup status"

# Block
["lsblk"]="_command lsblk"
["lsblk_t"]="_command lsblk -t"
["lsblk_D"]="_command lsblk -D"
["lsblk_scsi"]="_command lsblk --scsi"
["blkid"]="_command blkid -c /dev/null"
["blockdev"]="_command blockdev --report"
["ls_dev"]="_command ls -lanR /dev"
["ls_sys_block"]="_command ls -lanR /sys/block"
["parted-l"]="_command parted -l"

# Block Layer

# FCOE
["fcoeadm_i"]="_command fcoeadm -i"
["fcoeadm_f"]="_command fcoeadm -f"

# Infiniband
["infiniband_ibv_devices"]="_command ibv_devices"
["infiniband_ibv_devinfo"]="_command ibv_devinfo -v"
["infiniband_ibstat"]="_command ibstat"
["infiniband_ibstatus"]="_command ibstatus"

# WIP "ibhosts" "iblinkinfo" "sminfo" "perfquery"

# ISCSI
["iscsi_session"]="_command iscsiadm -m session -P 3"
["iscsi_nodes"]="_command iscsiadm -m node -P 1"
["iscsi_iface"]="_command iscsiadm -m iface -P 1"
["iscsi_nodes_op"]="_command iscsiadm -m node --op=show"

# ISCSI Target

["iscsi_tgtadm"]="_command tgtadm --lld iscsi --op show --mode target"

# LVM
["lvm_pvs_vgs_lvs"]="_lvm_pvs_vgs_lvs"
["lvm_pvs"]="_command pvs -a -v -o +pv_mda_free,pv_mda_size,pv_mda_count,pv_mda_used_count"
["lvm_vgs"]="_command vgs -v -o +vg_mda_count,vg_mda_free,vg_mda_size,vg_mda_used_count,vg_tags"
["lvm_lvs123"]="_command lvs -a -o +lv_tags,devices,lv_kernel_read_ahead,lv_read_ahead,stripes,stripesize"

["lvm_pvscan"]="_command pvscan -v"
["lvm_vgscan"]="_command vgscan -v"
["lvm_lvscan"]="_command lvscan -v"

["lvm_pvdisplay"]="_command pvdisplay -vv"
["lvm_vgdisplay"]="_command vgdisplay -vv"
["lvm_lvdisplay"]="_command lvdisplay -vv"

["collect_lvmdump"]="_command lvmdump -am"

# MDADM
#["mdadm_D"]="_command mdadm -D /dev/md*"  #Not tested #TODO


# Multipath
["multipath_ll"]="_command multipath -ll"  #Not tested #TODO


# Powerpath
["powermt_display"]="_command powermt display"
["powermt_dev_all"]="_command powermt display dev=all" # Not tested
["powermt_check_registration"]="_command powermt powermt check_registration"
["powermt_display_options"]="_command powermt display"
["powermt_display_ports"]="_command powermt display ports"
["powermt_display_paths"]="_command powermt display paths"
["powermt_dump"]="_command powermt dump"

# NVME
["nvme_list"]="_command nvme list"
["nvme_list_subsys"]="_command nvme list-subsys"
["nvme_get-ns-id="]="_command nvme get-ns-id $_arg"
["nvme_show-regs="]="_command nvme show-regs $_arg"
["nvme_id-ctrl="]="_command nvme id-ctrl $_arg"


# SCSI
["lsscsi"]="_command lsscsi -isg"
["sg_map"]="_command sg_map -x" #_need_sudo is failing
["scsi_id="]="_scsi_id $_arg"


# Scsi Layer

# systool

["systool_fchost"]="_command systool -c fc_host -v"
["systool_fc_remote_ports"]="_command systool -c fc_remote_ports -v -d"
["systool_fc_transport"]="_command systool -c fc_transport -v"
["systool_qla2xxx"]="_command systool -m qla2xxx -v"
["systool_scsi"]="_command systool -b scsi -v"
["systool_scsi_disk"]="_command systool -c scsi_disk -v"
["systool_scsi_host"]="_command systool -c scsi_host -v"
["systool_scsi_tape"]="_command systool -c scsi_tape -v"

# Targetcli
["targetcli_ls"]="_command targetcli ls"
["targetcli_status"]="_command targetcli status"
["targetcli_target_service"]="_command systemctl status target.service"

# VDO

)



### main() ###

i=0
while getopts 'hc:o:' OPTION; do
  case "$OPTION" in
    h)
      i=2
      usage
      ;;
    o)
      options="$OPTARG"
      _show_command=""
      ;;
    c)
      options="$OPTARG"
      _show_command="1"
      ;;
    ?)
      echo "script usage: \$systeminfo [-h] [-d domain] [-o option1,option2...]" >&2
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"



# options such as scsi=id=/dev/sdc get separated here and appropriate KEY is called from the dict _storage_command_dict
# It also splits multiple options provided on command line
# It also call appropriate  KEY for the option specified



_KEYS=(${!_storage_command_dict[@]})
_opt_keys=${_KEYS[@]}

if [ "$options" ]; then
  OPTIONS="$options"
  
  # For commands such as
  # systeminfo -d storage -o scsi_id=/dev/sdc

  _splitoption=$(echo $OPTIONS |awk '/=/{print $1}')

  if [ $_splitoption ]; then
    _parameter=$(echo "$OPTIONS" | cut -d"/" -f 1)
    #_parameter=$(echo "$OPTIONS" | cut -d"=" -f 1)
    _arg=$(echo "$OPTIONS" | cut -d"=" -f 2)
    if grep -wq "$_parameter" <<< "$_opt_keys"; then
      ${_storage_command_dict[$_parameter]} "$_arg"
      echo -e "\n"
    else
      echo "Invalid option \"$_parameter\" specified."
      echo "help: "
      echo -e "\t \$systeminfo -d <domain> -h"
    fi
  else
    # For commands such as
    # systeminfo -d storage -o device-mapper_table
    # systeminfo -d storage -o device-mapper_table,device-mapper_info
    _option=$(echo $OPTIONS | tr "," "\n")
    _KEYS=(${!_storage_command_dict[@]})
    _opt_keys=${_KEYS[@]}
    for i in $_option
      do
        if grep -wq "$_option" <<< "$_opt_keys"; then
          ${_storage_command_dict[$i]}
        else
          echo "Invalid option \"$_option\" specified."
          echo "help: "
          echo -e "\t \$systeminfo -d <domain> -h"
        fi
      done
  fi
else
  # If no options are specified and _-d domain_ is provided, we need to run _domain() and provide some
  # information about the domain
    if [ $i = "2" ]; then     #if -h is specified, it should not run _domain(), #systeminfo -d storage -h
      exit 0
    else
      _showdomain="_storage"     #if -h is not specified, run storage
      $_showdomain              #systeminfo -d storage
    fi
fi

unset _storage_command_dict
exit 0
