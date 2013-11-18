all:

install:
	
	# Some binaries used for droid system packaging.
	mkdir -p $(DESTDIR)/usr/bin/droid/ $(DESTDIR)/usr/libexec/droid/ $(DESTDIR)/usr/share/droid/src/
	install -m 755 bin/* $(DESTDIR)/usr/bin/droid/
	install -m 755 src/* $(DESTDIR)/usr/share/droid/src/
	
	# Udev rules for android container
	install -D -m 755 udev/platform-device $(DESTDIR)/lib/udev/platform-device
	install -D -m 644 udev/droid-system.rules $(DESTDIR)/lib/udev/rules.d/998-droid-system.rules
	
	# Causes kernel oops on the android devices, also rules that we dont need on the droid systems.
	mkdir -p $(DESTDIR)/etc/udev/rules.d/
	ln -s /dev/null $(DESTDIR)/etc/udev/rules.d/60-persistent-v4l.rules
	
	# Systemd files to start the android system.
	install -D -m 644 systemd/droid-hal-init.service $(DESTDIR)/lib/systemd/system/droid-hal-init.service
	mkdir -p $(DESTDIR)/lib/systemd/system/basic.target.wants/
	ln -s ../droid-hal-init.service $(DESTDIR)/lib/systemd/system/basic.target.wants/droid-hal-init.service
	install -D -m 644 systemd/droid-battery-monitor.service $(DESTDIR)/lib/systemd/system/droid-battery-monitor.service
	ln -s ../droid-battery-monitor.service/ $(DESTDIR)/lib/systemd/system/basic.target.wants/
	install -D -m 644 systemd/adbd.service $(DESTDIR)/lib/systemd/system/adbd.service
	
	# RPM macros
	install -D -m 644 macros/macros.droid $(DESTDIR)/etc/rpm/macros.droid

