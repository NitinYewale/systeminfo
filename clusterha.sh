#!/usr/bin/bash

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


usage()
{
echo -e "\n${Purple}Usage : systeminfo -d clusterha${NC} ${Green}[-o option1,option2,..]${NC}"

echo -e "\n${Green}[options]${NC} \t ${Cyan}- for domain clusterha${NC}"

echo -e "

pcs_config \t\tshow pcs cluster configuration
pcs_status \tshow pcs cluster status
gfs_coontrl_ls \t
gfs_contrl_dump \t

\n"

## Manual intervention needed here as of now. Need to figure out exporting this array to other files

## To get the list of options, comment the "COMMENT" lines and run "systeminfo -d storage -h".
## Copy the output to systeminfo_search.sh and to the bash completion script located at /etc/bash_completion.d

<<'COMMENT1'
_KEYS=(${!_clusterha_command_dict[@]})
_clusterha_arr=${_KEYS[@]}
echo $_clusterha_arr
COMMENT1

}

_clusterha()
{
echo "Selected clusterha"
}

_pcs_config()
{
  something about pcs config

}
declare -A _clusterha_command_dict

_clusterha_command_dict=(

# PCS

["pcs_config"]="_pcs_config"
["pcs_status"]="_command pcs status --full"

#GFS
["gfs_coontrl_ls"]="_command gfs_control ls -n"
["gfs_contrl_dump"]="_command gfs_control dump"

# rgmanager cluster commands
["cman_tool_status"]="_command cman_tool status"
["cman_tool_services"]="_command cman_tool services"
["cman_tool_nodes"]="_command cman_tool -a nodes"
["group_tool_dump"]="_command group_tool dump"
["group_tool_dump_gfs"]="_command group_tool dump gfs"
["group_tool_dump_fence"]="_command group_tool dump fence"
["ccs_tool_lsnode"]="_command ccs_tool lsnode"
["ccs_tool_lsfence"]="_command ccs_tool lsfence"
["clustat_fl"]="_command clustat -fl"



)


### main() ###

i=0
while getopts 'ho:' OPTION; do
  case "$OPTION" in
    h)
      i=2
      usage
      ;;
    o)
      options="$OPTARG"
      ;;
    ?)
      echo "script usage: \$systeminfo [-h] [-d domain1] [-o option1,option2...]" >&2
      #echo "script usage: $(basename $0) [-h] [-d domain1] [-o option1,option2...]" >&2
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"



# options such as scsi=id=/dev/sdc get separated here and appropriate KEY is called from the dict _clusterha_command_dict
# It also splits multiple options provided on command line
# It also call appropriate  KEY for the option specified

_KEYS=(${!_clusterha_command_dict[@]})
_opt_keys=${_KEYS[@]}

if [ "$options" ]; then
  OPTIONS="$options"
  # For commands such as
  # systeminfo -d storage -o scsi_id=/dev/sdc

  _splitoption=$(echo $OPTIONS |awk '/=/{print $1}')

  if [ $_splitoption ]; then

    _temp_parameter=$(echo "$OPTIONS" | cut -d"=" -f 1)
    _parameter=$_temp_parameter=

    _arg=$(echo "$OPTIONS" | cut -d"=" -f 2)

    if grep -q "$_parameter" <<< "$_opt_keys"; then
      ${_clusterha_command_dict[$_parameter]} "$_arg"
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
    _KEYS=(${!_clusterha_command_dict[@]})
    _opt_keys=${_KEYS[@]}
    for i in $_option
      do
        if grep -q "$_option" <<< "$_opt_keys"; then
          ${_clusterha_command_dict[$i]}
          #_call_options="$i"  #this and below line was used earlier instead of ${_clusterha_command_dict[$i]}
          #$_call_options
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
    if [ $i = 2 ]; then     #if -h is specified, it should not run _domain(), #systeminfo -d storage -h
      exit 0
    else
      _showdomain="_clusterha"     #if -h is not specified, run storage
      $_showdomain              #systeminfo -d clusterha
    fi
fi

unset _clusterha_command_dict
exit 0
