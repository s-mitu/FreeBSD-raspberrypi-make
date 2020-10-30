pkg install slim slim-freebsd-themes
cat << EOM > /etc/rc.conf.d/slim
slim_enable="YES"
EOM

sed -i.orig -e '/current_theme/s/default/freebsd-beastie/' /usr/local/etc/slim.conf
