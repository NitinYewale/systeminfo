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


#TO DO

# Array for Color options.

  declare -A c

    # Text Color 							Text Color + BOLD             # BackGround Color
	c[NC]='\033[0;0m'  						  c[BOLD]='\033[0;0m\033[1;1m'
	c[Dgrey]='\033[0;30m'  					c[BDgrey]='\033[1;30m'  		c[bg_Dgrey]='\033[40m'
	c[Red]='\033[0;31m'    					c[BRed]='\033[1;31m'    		c[bg_Red]='\033[41m'
	c[Green]='\033[0;32m'  					c[BGreen]='\033[1;32m'  		c[bg_Green]='\033[42m'
	c[Orange]='\033[0;33m' 					c[BOrange]='\033[1;33m' 		c[bg_Orange]='\033[43m'
	c[Blue]='\033[0;34m'   					c[BBlue]='\033[1;34m'   		c[bg_Blue]='\033[44m'
	c[Purple]='\033[0;35m' 					c[BPurple]='\033[1;35m' 		c[bg_Purple]='\033[45m'
	c[Cyan]='\033[0;36m'   					c[BCyan]='\033[1;36m'   		c[bg_Cyan]='\033[46m'
	c[Lgrey]='\033[0;37m'  					c[BLgrey]='\033[1;37m'  		c[bg_Lrey]='\033[47m'
    c[Yellow]='\033[0;33m'

	# Underline
	c[UBlack]='\033[4;30m'       # Black
	c[URed]='\033[4;31m'         # Red
	c[UGreen]='\033[4;32m'       # Green
	c[UYellow]='\033[4;33m'      # Yellow
	c[UWhite]='\033[4;37m'       # White
	c[UCyan]='\033[4;36m'        # Cyan


SYSTEMINFO_VERSION="0.1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! [ -f "$DIR/lib_systeminfo.sh" ]; then
  DIR="/usr/share/systeminfo-$SYSTEMINFO_VERSION"
fi

_exists()
{
  command -v "$1" |grep -qv alias >/dev/null 2>&1
}

_need_sudo()
{
  # Check whether the command is under /*sbin*
  command -v $1 | grep sbin >/dev/null 2>&1


  if [ "$?" -eq "0" ]; then
    _needsudo="1"
    prompt=$(sudo -nl pvs 2>&1)  #"pvs" is a random command that needs root/sudo privileges 
    if [ $? -eq 1 ]; then
      echo -e "\nRoot/sudo privileges are needed to execute the \"$_executable\" command. \n"
      exit 0
    else
       _needsudo="1"
    fi
  else
    _needsudo=""
  fi

  _exception_commands=( /lib/udev/scsi_id sg_map )
  _opt_commands=${_exception_commands[@]}
  if grep -q "$1" <<< "$_opt_commands"; then
    _needsudo="1"
    prompt=$(sudo -nl pvs 2>&1)
    if [ $? -eq 1 ]; then
      echo -e "\nRoot privileges are needed to execute the \"$_executable\" command. \n"
      exit 0
    else
      _needsudo="1"
    fi
  fi
}


_command()
{
command_a=($1)
_executable=${command_a[0]}
if _exists $_executable; then
  if [ `id -u` -gt "0" ]; then
    _need_sudo $_executable
    if [ ! "$_needsudo" ]; then
      echo -e "${c[Cyan]}Command :${c[NC]} $* \n"
      if [ ! "$_show_command" ]; then
        echo -e "${c[Yellow]}Output :${c[NC]} \n"
        $*
        echo -e "\n"
      else
        exit 0
      fi
    else
      echo -e "${c[Cyan]}Command :${c[NC]} sudo $* \n"
      if [ ! "$_show_command" ]; then
        echo -e "${c[Yellow]}Output :${c[NC]} \n"
        sudo $*
        echo -e "\n"
      else
        exit 0
      fi
      #echo -e "${c[Yellow]}Output :${c[NC]} \n"
      #sudo $*
      #echo -e "\n"
    fi
  else
    echo -e "${c[Cyan]}Command :${c[NC]} $* \n"
    if [ ! "$_show_command" ]; then
      echo -e "${c[Yellow]}Output :${c[NC]} "
      $*
      echo -e "\n"
    else
      exit 0
    fi
  fi
else
  echo -e "Your system does not have \"$_executable\" command \n"
  echo -e "-----------------------------------------------------"
fi
}

### Syntax for writing custom functions
_custom_function()
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
