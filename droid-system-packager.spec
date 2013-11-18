Summary: 	Droid BSP packager
License: 	BSD-3-Clause
Name: 		droid-system-packager
Version: 0.1
Release: 1
Source0: 	%{name}-%{version}.tar.bz2
Group:		Development/Tools
BuildArch:	noarch

%description
%{summary}.

%package devel
Group:	Development/Tools
Requires: %{name} = %{version}-%{release}
Summary: Development files for droid system packaging

%description devel
%{summary}.

%prep
# Adjusting %%setup since git-pkg unpacks to src/
# %%setup -q
%setup -q -n src

%build
make

%install
rm -rf $RPM_BUILD_ROOT
%make_install

%files
%defattr(-,root,root,-)
%config /etc/rpm/macros.droid
/lib/udev/platform-device
/lib/udev/rules.d/998-droid-system.rules
/lib/systemd/system/droid-hal-init.service
/lib/systemd/system/basic.target.wants/droid-hal-init.service
/lib/systemd/system/droid-battery-monitor.service
/lib/systemd/system/basic.target.wants/droid-battery-monitor.service
/lib/systemd/system/adbd.service
/etc/udev/rules.d/60-persistent-v4l.rules
%{_bindir}/droid/droid-init-done.sh
%{_bindir}/droid/kill-cgroup.sh
%{_bindir}/droid/droid-hal-startup.sh

%files devel
%defattr(-,root,root,-)
%{_bindir}/droid/droid-system-prepare.sh
%{_bindir}/droid/droid-system-precheck.sh
%{_bindir}/droid/fstab-to-systemd-services.sh
%attr(644,root,root) %{_datadir}/droid/src/*

