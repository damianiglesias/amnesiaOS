#!/bin/bash
# AmnesiaOS - Build bootable ISO
set -e

ISO_ROOT="/tmp/amnesia-isoroot"
OUTPUT="$HOME/amnesia-os.iso"
KERNEL="/boot/vmlinuz-6.16.1-lfs"
INITRAMFS="/boot/initramfs-6.16.1.img"

echo "[*] Building AmnesiaOS ISO..."

mkdir -pv $ISO_ROOT/boot/grub

cp -v $KERNEL $ISO_ROOT/boot/vmlinuz
cp -v $INITRAMFS $ISO_ROOT/boot/initramfs.img

cat > $ISO_ROOT/boot/grub/grub.cfg << 'EOF'
set default=0
set timeout=5

menuentry "AmnesiaOS - RAM Boot" {
    linux /boot/vmlinuz init=/init rw console=tty1
    initrd /boot/initramfs.img
}

menuentry "AmnesiaOS - RAM Boot (verbose)" {
    linux /boot/vmlinuz init=/init rw console=tty1 debug
    initrd /boot/initramfs.img
}
EOF

grub-mkrescue -o $OUTPUT $ISO_ROOT

echo "[+] ISO ready: $OUTPUT ($(du -sh $OUTPUT | cut -f1))"