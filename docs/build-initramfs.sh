#!/bin/bash
# AmnesiaOS - Build initramfs
set -e

INITRAMFS_DIR="/initramfs"
OUTPUT="/boot/initramfs-6.16.1.img"
BUSYBOX_URL="https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox"

echo "[*] Building AmnesiaOS initramfs..."

# Create structure
mkdir -pv $INITRAMFS_DIR/{bin,dev,etc,lib,lib64,proc,sys,tmp,mnt/root,root,run,sbin,usr/{bin,sbin,lib}}

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
           head tail sleep hostname dmesg su login wget; do
    ln -sfv busybox $INITRAMFS_DIR/bin/$cmd
done

# Create device nodes
mknod -m 622 $INITRAMFS_DIR/dev/console c 5 1 2>/dev/null || true
mknod -m 666 $INITRAMFS_DIR/dev/null c 1 3 2>/dev/null || true
mknod -m 666 $INITRAMFS_DIR/dev/tty c 5 0 2>/dev/null || true

# Create init
cat > $INITRAMFS_DIR/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null
echo "AmnesiaOS - RAM boot OK"
exec /bin/sh
EOF
chmod +x $INITRAMFS_DIR/init

# Pack
echo "[*] Packing initramfs..."
cd $INITRAMFS_DIR
find . | cpio -o -H newc | gzip -9 > $OUTPUT

echo "[+] Done: $OUTPUT ($(du -sh $OUTPUT | cut -f1))"