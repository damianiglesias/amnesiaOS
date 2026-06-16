#!/bin/bash
# AmnesiaOS - Build initramfs
set -e

INITRAMFS_DIR="/initramfs"
OUTPUT="/boot/initramfs-6.16.1.img"
BUSYBOX_URL="https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox"

echo "[*] Building AmnesiaOS initramfs..."

# Create structure
mkdir -pv $INITRAMFS_DIR/{bin,dev,etc,lib,lib64,proc,sys,tmp,mnt/root,root,run,sbin,usr/{bin,sbin,lib,share/udhcpc}}

# Download BusyBox if not present
if [ ! -f "$INITRAMFS_DIR/bin/busybox" ]; then
    echo "[*] Downloading BusyBox..."
    wget -O $INITRAMFS_DIR/bin/busybox $BUSYBOX_URL
    chmod +x $INITRAMFS_DIR/bin/busybox
fi

# Create symlinks
echo "[*] Creating utility symlinks..."
for cmd in sh mount umount cp ls cat mkdir rm mv pwd echo grep \
           sed awk find chmod chown ln ps kill top df free uname \
           date ip ifconfig ping tar gzip gunzip vi more less \
           head tail sleep hostname dmesg su login wget basename \
           udhcpc; do
    ln -sfv busybox $INITRAMFS_DIR/bin/$cmd
done

# Create device nodes
mknod -m 622 $INITRAMFS_DIR/dev/console c 5 1 2>/dev/null || true
mknod -m 666 $INITRAMFS_DIR/dev/null c 1 3 2>/dev/null || true
mknod -m 666 $INITRAMFS_DIR/dev/tty c 5 0 2>/dev/null || true

# Create DHCP client script (applies IP, gateway and DNS from udhcpc)
echo "[*] Creating udhcpc configuration script..."
cat > $INITRAMFS_DIR/usr/share/udhcpc/default.script << 'EOF'
#!/bin/sh
case "$1" in
    deconfig)
        ip addr flush dev "$interface"
        ;;
    bound|renew)
        ip addr add "$ip"/"${mask:-${subnet:-24}}" dev "$interface"
        if [ -n "$router" ]; then
            ip route add default via "$router" dev "$interface"
        fi
        if [ -n "$dns" ]; then
            > /etc/resolv.conf
            for d in $dns; do
                echo "nameserver $d" >> /etc/resolv.conf
            done
        fi
        ;;
esac
exit 0
EOF
chmod +x $INITRAMFS_DIR/usr/share/udhcpc/default.script

touch $INITRAMFS_DIR/etc/resolv.conf

# Create init
cat > $INITRAMFS_DIR/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null

echo "AmnesiaOS - RAM boot OK"
echo "Configuring network..."

ip link set lo up 2>/dev/null

for iface in /sys/class/net/*; do
    name=${iface##*/}
    if [ "$name" != "lo" ]; then
        ip link set "$name" up 2>/dev/null
        udhcpc -i "$name" -n -q -s /usr/share/udhcpc/default.script 2>/dev/null && echo "Network configured on $name"
    fi
done

exec /bin/sh
EOF
chmod +x $INITRAMFS_DIR/init

# Pack
echo "[*] Packing initramfs..."
cd $INITRAMFS_DIR
find . | cpio -o -H newc | gzip -9 > $OUTPUT

echo "[+] Done: $OUTPUT ($(du -sh $OUTPUT | cut -f1))"