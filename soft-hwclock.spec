%define debug_package %{nil}

%define mybuildnumber %{?build_number}%{?!build_number:1}

Name:           soft-hwclock
Version:        0.2023.1.5
Release:        %{mybuildnumber}%{?dist}
Summary:        Simple script based fake-hwclock for systemd systems 
BuildArch:      noarch

License:        MIT
URL:            https://github.com/Rudd-O/%{name}
Source0:        https://github.com/Rudd-O/%{name}/archive/{%version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  make
BuildRequires:  sed
BuildRequires:  systemd
BuildRequires:  systemd-rpm-macros
Requires:       bash
Requires:       coreutils

%description
Many simple systems, such as the Raspberry PI, don't have hardware clocks.
When they boot, they start with their system clock set at some fixed date,
e.g. 2000/01/01 00:00:00.

A soft hwclock sets the initial time to some known value from before the last
reboot. This brings the clock into a sensible range prior to getting a better
value from network based services such as ntp. Should the network not be
available, services can continue to run from where they left off, avoiding
problems with an internal clock set far in the past conflicting with recent
timestamps.

Some systems have packages to do womething similar, while others don't.
This repository consists of shell scripts and service files for systemd based
systems to achieve this, and has been tested on a Raspberry Pi 3 running
CentOS 7.

%prep
%setup -q

%build
make DESTDIR=$RPM_BUILD_ROOT BINDIR=%{_bindir} SHAREDSTATEDIR=%{_sharedstatedir} UNITDIR=%{_unitdir}

%install
rm -rf $RPM_BUILD_ROOT
# variables must be kept in sync with build
make install DESTDIR=$RPM_BUILD_ROOT BINDIR=%{_bindir} SHAREDSTATEDIR=%{_sharedstatedir} UNITDIR=%{_unitdir}

%check
if grep -r '@.*@' $RPM_BUILD_ROOT ; then
    echo "Check failed: files with AT identifiers appeared" >&2
    exit 1
fi

%post
%systemd_post %{name}-tick.timer
%systemd_post %{name}.service

%preun
%systemd_post %{name}.service
%systemd_preun %{name}-tick.timer

%postun
%systemd_postun %{name}-tick.timer
%systemd_postun %{name}.service

%files
%attr(0755, root, root) %{_bindir}/%{name}
%attr(-, root, root) %{_sharedstatedir}/%{name}
%attr(0644, root, root) %{_unitdir}/%{name}*
%doc README.md

%changelog
* Fri Jan 6 2023 Manuel Amador (Rudd-O) <rudd-o@rudd-o.com>
- Initial release

