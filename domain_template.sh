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


usage()
{

echo -e "\n${c[Purple]}Usage : systeminfo -d domain_template${c[NC]} ${c[Green]}[-o option1,option2,..]${c[NC]}"

echo -e "\n${c[BGreen]}[options]${c[NC]} \t ${c[UCyan]}- for domain domain_template${c[NC]}"

echo -e "

pcs_config \t\tshow pcs cluster configuration
pcs_status \t\tshow pcs cluster status


\n"

## Manual intervention needed here as of now. Need to figure out exporting this array to other files

## To get the list of options, comment the "COMMENT" lines and run "systeminfo -d storage -h".
## Copy the output to systeminfo_search.sh and to the bash completion script located at /etc/bash_completion.d

#<<'COMMENT1'
#_KEYS=(${!_domain_template_command_dict[@]})
#_domain_template_arr=${_KEYS[@]}
#echo $_domain_template_arr
#COMMENT1

}

_domain_template()
{
# This function shows the information for the command `syteminfo -d domain_name`
echo "Selected domain_template"
}

_pcs_config()
{

  echo "pcs config"
}
declare -A _domain_template_command_dict

_domain_template_command_dict=(

# [option]="command or function name should come here"

["pcs_config"]="_pcs_config"  
["pcs_status"]="_command pcs status --full" 


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



# options such as scsi=id=/dev/sdc get separated here and appropriate KEY is called from the dict _domain_template_command_dict
# It also splits multiple options provided on command line
# It also call appropriate  KEY for the option specified

_KEYS=(${!_domain_template_command_dict[@]})
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
    if grep -q "$_parameter" <<< "$_opt_keys"; then
      ${_domain_template_command_dict[$_parameter]} "$_arg"
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
    _KEYS=(${!_domain_template_command_dict[@]})
    _opt_keys=${_KEYS[@]}
    for i in $_option
      do
        if grep -q "$_option" <<< "$_opt_keys"; then
          ${_domain_template_command_dict[$i]}
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
      _showdomain="_domain_template"     #if -h is not specified, run storage
      $_showdomain              #systeminfo -d domain_template
    fi
fi

unset _domain_template_command_dict
exit 0
