#!/bin/sh

imagedir=images
image=$(curl -s ftp://download.freebsd.org/pub/FreeBSD/snapshots/ISO-IMAGES/13.0/ | sed -e '/RPI3/s/.*[^-/]\(FreeBSD-13.0-CURRENT-arm64-aarch64-RPI3[^[:space:]]*.xz\).*/\1/p;d' | tail -n 1)
chksum=CHECKSUM.SHA256-$(basename ${image} .img.xz)
if [ $? -eq 0 ]; then
	mkdir -p ${imagedir}
	if [ ! -f ${imagedir}/${image} ]; then
		curl -o ${imagedir}/${image} ftp://download.freebsd.org/pub/FreeBSD/snapshots/ISO-IMAGES/13.0/${image} || exit 1
	fi
	if [ ! -f ${imagedir}/${chksum} ]; then
		curl -o ${imagedir}/${chksum} ftp://download.freebsd.org/pub/FreeBSD/snapshots/ISO-IMAGES/13.0/${chksum} || exit 1
	fi
	match=`(sha256  ${imagedir}/${image}; cat ${imagedir}/${chksum} ) | awk '{print $NF}' | uniq | wc -l`
	if [ ${match} -ne 1 ] ;then 
		echo "Checksum mismatch"
		exit 2
	fi

	ln -sf ${imagedir}/${image} "$1"
fi

