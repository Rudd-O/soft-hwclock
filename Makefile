BINDIR=/usr/local/bin
SHAREDSTATEDIR=/usr/local/var/lib
UNITDIR=/etc/systemd/system
DESTDIR=
PROGNAME=soft-hwclock
CLOCKFILE=$(SHAREDSTATEDIR)/$(PROGNAME)/$(PROGNAME).data
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: clean dist rpm srpm install

all: $(PROGNAME) $(PROGNAME).service $(PROGNAME)-tick.service

clean:
	find -name '*~' -print0 | xargs -0 rm -fv
	rm -fv *.tar.gz *.rpm
	rm -f $(PROGNAME).service $(PROGNAME)-tick.service $(PROGNAME)

dist: clean
	excludefrom= ; test -f .gitignore && excludefrom=--exclude-from=.gitignore ; DIR=$(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec` && FILENAME=$$DIR.tar.gz && tar cvzf "$$FILENAME" --exclude="$$FILENAME" --exclude=.git --exclude=.gitignore $$excludefrom --transform="s|^|$$DIR/|" --show-transformed *

rpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ta $(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/RPMS/*/* "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

srpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ts $(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

$(PROGNAME): $(PROGNAME).in
	cd $(ROOT_DIR) && \
	cat $< | \
	sed "s|@CLOCKFILE@|$(CLOCKFILE)|" \
	> $@

$(PROGNAME).service: $(PROGNAME).service.in
	cd $(ROOT_DIR) && \
	cat $< | \
	sed "s|@BINDIR@|$(BINDIR)|" \
	> $@

$(PROGNAME)-tick.service: $(PROGNAME)-tick.service.in
	cd $(ROOT_DIR) && \
	cat $< | \
	sed "s|@BINDIR@|$(BINDIR)|" | \
	> $@

install: all
	install -Dm 755 "$(PROGNAME)" -t "$(DESTDIR)/$(BINDIR)/"
	install -Dm 644 "$(PROGNAME).service" -t "$(DESTDIR)/$(UNITDIR)/"
	install -Dm 644 "$(PROGNAME)-tick.timer" -t "$(DESTDIR)/$(UNITDIR)/"
	install -Dm 644 "$(PROGNAME)-tick.service" -t "$(DESTDIR)/$(UNITDIR)/"
	mkdir -p "$(DESTDIR)/$(SHAREDSTATEDIR)/$(PROGNAME)"
	touch "$(DESTDIR)/$(SHAREDSTATEDIR)/$(PROGNAME)/$(PROGNAME)".data
