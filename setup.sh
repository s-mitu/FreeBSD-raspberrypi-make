#!/bin/sh

# fstab
sed -i.orig 's/rw /rw,noatime /' /etc/fstab

# zoneinfo
cp /usr/share/zoneinfo/Japan /etc/localtime 

#ntpdate
echo "ntpdate_enable=YES" > /etc/rc.conf.d/ntpdate
service ntpdate start

# powerd
echo powerd_enable="YES" > /etc/rc.conf.d/powerd
service powerd start

# install pkgs
pkg install -y fluxbox \
	x11-drivers/xf86-video-scfb \
	xterm \
	lxterminal \
	xinit \
	x11-fonts/noto-jp \
	x11-drivers/xf86-input-keyboard \
	x11-drivers/xf86-input-mouse \
	x11-drivers/xf86-input-evdev \
	ja-ibus-mozc \
	dbus \
	sudo
echo "dbus_enable=YES" > /etc/rc.conf.d/dbus
service dbus start

#sudo
echo "freebsd ALL=(ALL) ALL" > /usr/local/etc/sudoers.d/freebsd
chmod 440 /usr/local/etc/sudoers.d/freebsd

# xinitrc
awk '/^twm/{exit}{print}' <  /usr/local/etc/X11/xinit/xinitrc > /home/freebsd/.xinitrc
cat << EOM >> /home/freebsd/.xinitrc
# global
export LANG=ja_JP.UTF-8
# ibus-mozc
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=xim
export XMODIFIERS=@im=ibus
/usr/local/bin/mozc start
ibus-daemon -r --daemonize --xim
# wm
exec fluxbox
EOM
chown freebsd:freebsd /home/freebsd/.xinitrc

# install xfce4
pkg install -y x11-wm/xfce4-wm  x11-wm/xfce4-session  x11-wm/xfce4-panel  x11-wm/xfce4-desktop  sysutils/xfce4-settings xfce4-terminal
