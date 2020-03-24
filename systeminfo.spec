Name:           systeminfo
Version:        0.1
Release:        0
Summary:        systeminfo is an utilty which simplifies running commands.
Group:          Applications/File
License:        GPLv2
Source0:        systeminfo-0.1.tar.gz
BuildArch:      noarch

Packager: Nitin U. Yewale <nyewale@redhat.com>

BuildRequires:  /bin/rm, /bin/mkdir, /bin/cp
Requires:       /bin/bash


%description
systeminfo : systeminfo is an utilty which simplifies running commands.

The systeminfo utility displays the system information.

This utility takes only two arguments which need to be supplied with -d [domain] and -o [option]
domain and options arguments are optional.

Domain represents the OS component.

To see the information at further granular level, use "-o option".

This would also show the OS command that runs in the background to provide that information.


%prep
%setup -q -n systeminfo-0.1


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/share/systeminfo-0.1
mkdir -p $RPM_BUILD_ROOT/etc/bash_completion.d/

cp systeminfo.bash $RPM_BUILD_ROOT/etc/bash_completion.d/
cp README LICENSE $RPM_BUILD_ROOT/usr/share/systeminfo-0.1/
cp clusterha.sh domain_template.sh lib_systeminfo.sh s* $RPM_BUILD_ROOT/usr/share/systeminfo-0.1/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/etc/bash_completion.d/systeminfo.bash
/usr/share/systeminfo-0.1/*

%post
ln -s /usr/share/systeminfo-0.1/systeminfo /usr/bin/systeminfo
source /etc/bash_completion.d/systeminfo.bash


%postun
unlink /usr/bin/systeminfo
rm -f /etc/bash_completion.d/systeminfo.bash
rm -rf /usr/share/systeminfo-0.1

%changelog
* Tue Mar 17 2020 Nitin U. Yewale <nyewale@redhat.com>
- Initial release for systeminfo.
