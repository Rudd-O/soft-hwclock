BINDIR=/usr/local/bin
SHAREDSTATEDIR=/usr/local/var/lib
UNITDIR=/etc/systemd/system
DESTDIR=
PROGNAME=soft-hwclock

clean:
	find -name '*~' -print0 | xargs -0 rm -fv
	rm -fv *.tar.gz *.rpm

dist: clean
	excludefrom= ; test -f .gitignore && excludefrom=--exclude-from=.gitignore ; DIR=$(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec` && FILENAME=$$DIR.tar.gz && tar cvzf "$$FILENAME" --exclude="$$FILENAME" --exclude=.git --exclude=.gitignore $$excludefrom --transform="s|^|$$DIR/|" --show-transformed *

rpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ta $(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/RPMS/*/* "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

srpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ts $(PROGNAME)-`awk '/^Version:/ {print $$2}' $(PROGNAME).spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

install:
	install -Dm 755 bin/"$(PROGNAME)" -t "$(DESTDIR)/$(BINDIR)/"
	install -Dm 644 bin/"$(PROGNAME).service" -t "$(DESTDIR)/$(UNITDIR)/"
	install -Dm 644 bin/"$(PROGNAME)-tick.timer" -t "$(DESTDIR)/$(UNITDIR)/"
	install -Dm 644 bin/"$(PROGNAME)-tick.service" -t "$(DESTDIR)/$(UNITDIR)/"
	mkdir -p "$(DESTDIR)/$(SHAREDSTATEDIR)/$(PROGNAME)"
	touch "$(DESTDIR)/$(SHAREDSTATEDIR)/$(PROGNAME)/$(PROGNAME)".data
