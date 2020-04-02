# systeminfo

systeminfo utility simplifies running linux commands and the best part is we do not need to remember the actual commands.
It is a great tool for learning commands and linux topics as well as it provides a simplified interface for learning commands.

The systeminfo utility displays the system information when run without any options.
This utility takes only two arguments which need to be supplied with -d [domain] and -o [option]
domain and options arguments are optional.

Domain represents the OS component and options is the sub-component.

In Linux there are several commands and it becomes difficult to remember them all, additionally changing configuration too needs command and understanding of the subject and file contents. Systeminfo utility should make using command simpler.

Why we need this utility
- Use case
  L1 L2 system admins and admins working with various components. Basically all admins.
  TAMs and Solution architects for reading the current status on the fly and many others...

-----------------------------------------------------------------------------------------------------------------------------------

- How does it work / example commands

  systeminfo
  systeminfo -d <domain>
  systeminfo -d <domain> -o <option1,option2..>
  systeminfo -d <domain> -o scsi_id=<something>
  <something depends on the option that is specified with the "=", equalto sign >
  See `systeminfo -d domain -h` for more information on what the something would be

  If you do not wish to execute the command, use the '-c' switch for options
    systeminfo -d <domain> -c <option>

- Search
 systeminfo -s something   <-- search something


  Use -h for help
   
  systeminfo -h            <---- will give list of domains (in alphabetical order)
  systeminfo -d domain -h     <---- will give additional options to use with the domains (in alphabetical order)


-----------------------------------------------------------------------------------------------


Features :

> Not designed to make any changes to the system
> Provide helpful information about command that could do modification, about configuration files etc..
  For example :

      systeminfo -d storage -o lvm_help

      Could include helpful commands for modification of LVM devices. 
      Could include helpful files/configuration files to check
      Any other helpful information

	  Name of the *help* file. 

	  domain_help  --> storage_help, clusterha_help  etc..
	  OR
	  major_option_help  -->  iscsi_help, lvm_help etc..

	  There could be multiple *help* files for particular domain.


> troubleshooting information could be included separately on in topic_help files

     	How to enable/disable debugging for various components.

> Check for common errors / misconfigurations
  
  domain_check OR topic_check option

-----------------------------------------------------------------------------------------------


- How can we test this


1. Need to test with root, sudo and with normal user privileges 

2.a. Install RPM 

2.b. Copy the directory systeminfo

  cd systeminfo

  Run :
    bash systeminfo.sh -d clusterha -h

    OR

   ./systeminfo.sh -d clusterha -h

    OR

    Create alias in bashrc file

    alias systeminfo="bash /<path>/systeminfo.sh"

-----------------------------------------------------------------------------------------------

Contribution :


Copy domain_template.sh and add the commands to _domain_template_command_dict.

Rules for writing commands and options :

1. Command name needs to start with executable. For example : 'pvs -a -o +device'. 
   Please avoid starting with grep, awk unless using custom function.

2. If command contains "|" _pipe_ symbol, it is not getting executed through _command as of now
   We could use custom function, do necessary checks and run the command.

3. Ensure that commands are tested with root user / sudo user as well as with normal user.


===================================================================================================

Date : Mar 2nd, 2020

Added "-c" option
This would display the command. Command would not get executed.


