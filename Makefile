IMAGE_NAME=freebsd-pi.img
MDNO=5
UBOOT_FILES=u-boot.bin fixup4.dat start4.elf
SETUP_SCRIPTS=setup.sh setup-xlogin-slim.sh
default: pi-image

# Fetch files
pibase.img.xz:
	pwd
	./fetch-current.sh $@

# Copy u-boot files
u-boot.bin:
	curl -O https://versaweb.dl.sourceforge.net/project/rpi4-8gbram-boot-fbsdonly/u-boot.bin

fixup4.dat:
	curl -O https://raw.githubusercontent.com/raspberrypi/firmware/1.20200717/boot/fixup4.dat

start4.elf:
	curl -O https://raw.githubusercontent.com/raspberrypi/firmware/1.20200717/boot/start4.elf

# fetch all
fetch:pibase.img.xz $(UBOOT_FILES)

# File copy
$(IMAGE_NAME) : pibase.img.xz
	xzcat ${.ALLSRC} > $@

# Create MD
/dev/md$(MDNO)s1:$(IMAGE_NAME)
	sudo mdconfig -a -u $(MDNO) -t vnode -f $(IMAGE_NAME) 

# Attach md
attach:/dev/md$(MDNO)s1

# Install u-boot
install-u-boot: $(UBOOT_FILES) /dev/md$(MDNO)s1
	sudo mount_msdosfs -u `id -u`  /dev/md$(MDNO)s1 /media
	cp $(UBOOT_FILES) /media
	sudo umount /media

# Install setup scripts
install-setupscripts: $(UBOOT_FILES) /dev/md$(MDNO)s1
	sudo mount_msdosfs -u `id -u`  /dev/md$(MDNO)s1 /media
	cp $(SETUP_SCRIPTS) /media
	sudo umount /media

# Detach md
detach:
	sudo mdconfig -d -u $(MDNO)

# Create zip
$(IMAGE_NAME).zip:$(IMAGE_NAME)
	zip $(IMAGE_NAME).zip $(IMAGE_NAME)

zip: $(IMAGE_NAME).zip

pi-image: attach install-u-boot install-setupscripts detach zip

pi-image-dd: $(IMAGE_NAME).zip


clean:
	rm pibase.img.xz $(UBOOT_FILES) $(IMAGE_NAME)
