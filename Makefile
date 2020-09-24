IMAGE_NAME=freebsd-pi.img
MDNO=5
UBOOT_FILES=u-boot.bin fixup4.dat start4.elf

default: pi-image

# Fetch files
pibase.img.xz:
	./fettch-current.sh $@

u-boot.bin:
	curl -O https://versaweb.dl.sourceforge.net/project/rpi4-8gbram-boot-fbsdonly/u-boot.bin

fixup4.dat:
	curl -O https://raw.githubusercontent.com/raspberrypi/firmware/1.20200717/boot/fixup4.dat

start4.elf:
	curl -O https://raw.githubusercontent.com/raspberrypi/firmware/1.20200717/boot/start4.elf

fetch:pibase.img.xz $(UBOOT_FILES)

# File copy
$(IMAGE_NAME) : pibase.img.xz
	xzcat ${.ALLSRC} > $@

/dev/md$(MDNO)s1:$(IMAGE_NAME)
	sudo mdconfig -a -u $(MDNO) -t vnode -f $(IMAGE_NAME) 

attach:/dev/md$(MDNO)s1

install-u-boot: $(UBOOT_FILES) /dev/md$(MDNO)s1
	sudo mount_msdosfs -u `id -u`  /dev/md$(MDNO)s1 /media
	cp $(UBOOT_FILES) /media
	sudo umount /media

detach:
	sudo mdconfig -d -u $(MDNO)

pi-image: attach install-u-boot detach

clean:
	rm pibase.img.xz $(UBOOT_FILES)
