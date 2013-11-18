
all:
	gcc -I $(INCLUDEDIR) -o $(DESTDIR)/filesgen filesgen.c
	gcc -I $(INCLUDEDIR) -o $(DESTDIR)/usergroupgen usergroupgen.c
	$(DESTDIR)/usergroupgen > $(DESTDIR)/user-group-create.sh

install:
	mkdir -p $(DESTDIR)/usr/lib/pkgconfig/
	sed s/@device@/$(DEVICE)/g android-headers.pc.in > $(DESTDIR)/usr/lib/pkgconfig/android-headers.pc

