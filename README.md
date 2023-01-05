# soft-hwclock

## description

Many simple systems, such as the Raspberry PI, don't have hardware clocks.
When they boot, they start with their system clock set at some fixed date, e.g. 2000/01/01 00:00:00.

A _soft_ hwclock sets the initial time to some known value from before the last reboot.  This brings
the clock into a _sensible_ range prior to getting a better value from network based services
such as _ntp_.  Should the network not be available, services can continue to run from where they
left off, avoiding problems with an internal clock set far in the past conflicting with recent
timestamps.

Some systems have packages to do womething similar, while others don't.  This repository consists of
shell scripts and service files for _systemd_ based systems to achieve this, and has been
tested on a Raspberry Pi 3 running CentOS 7

## features

Sets the time to a "recent" timestamp early in the boot to avoid timestamps
far in the past when booting, prior to getting a proper timestamp from the network.

- Restores the system clock from file during early boot
- Saves the clock into a file at shutdown
- Regularly saves the current time into the data file, in case of improper shutdown.
- shell based to avoid platform and binary dependencies.
- contains soft-hwclock.service and soft-hwclock.timer systemd units.

## installation:

From source:

* Simply type `make install` in the source folder.  The top of the Makefile
contains the default locations to which everything will be installed.
* You can then start the services with `make start`.

RPMs for Fedora 36 and later are available at https://repo.rudd-o.com .

## See also:
This package is inspired by Steve McIntyre's [fake-hwclock package for Debian.][fake-hwclock]
and forked from Kristján Valur Jónsson's [soft-hwclock package][soft-hwclock]
to make it easier to install on RPM-based systems.

[fake-hwclock]: https://tracker.debian.org/pkg/fake-hwclock
[soft-hwclock]: https://github.com/kristjanvalur/soft-hwclock
