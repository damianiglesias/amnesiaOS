# Building AmnesiaOS from Source

This document describes how to build AmnesiaOS from scratch.

## Prerequisites

- A Linux host system (Debian/Ubuntu recommended)
- At least 30GB of free disk space
- 4GB+ RAM
- Internet connection

## Dependencies

```bash
sudo apt install -y build-essential gcc g++ make bison flex \
    libncurses-dev libssl-dev libelf-dev bc xorriso grub-pc-bin \
    grub-efi-amd64-bin mtools wget
```

## Build Process

### 1. Build the toolchain (LFS chapters 5-7)

Follow the Linux From Scratch book to build the cross-compilation toolchain.
The toolchain targets `x86_64-pc-linux-gnu`.

### 2. Build core packages (LFS chapter 8)

Key packages built from source:
- glibc 2.42
- GCC 15.2.0
- binutils 2.45
- Linux kernel 6.16.1

### 3. Configure the kernel

```bash
cd linux-6.16.1
make x86_64_defconfig
scripts/config --enable CONFIG_BLK_DEV_INITRD
scripts/config --enable CONFIG_TMPFS
scripts/config --enable CONFIG_SQUASHFS
scripts/config --disable CONFIG_MODULE_SIG
make olddefconfig
make
```

### 4. Build the initramfs

```bash
# Download BusyBox static binary
wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox

# Create initramfs structure
mkdir -p initramfs/{bin,dev,etc,lib,lib64,proc,sys,tmp,mnt/root}
cp busybox initramfs/bin/busybox
chmod +x initramfs/bin/busybox

# Create symlinks
for cmd in sh mount cp ls cat mkdir rm mv pwd echo grep \
           sed awk find chmod ps kill df free uname date \
           ip ping tar gzip vi hostname dmesg; do
    ln -s busybox initramfs/bin/$cmd
done

# Create init script
cat > initramfs/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null
echo "AmnesiaOS - RAM boot OK"
exec /bin/sh
EOF
chmod +x initramfs/init

# Pack initramfs
cd initramfs
find . | cpio -o -H newc | gzip -9 > ../boot/initramfs.img
```

### 5. Create bootable ISO

```bash
mkdir -p isoroot/boot/grub
cp boot/vmlinuz isoroot/boot/
cp boot/initramfs.img isoroot/boot/

cat > isoroot/boot/grub/grub.cfg << 'EOF'
menuentry "AmnesiaOS" {
    linux /boot/vmlinuz init=/init rw console=tty1
    initrd /boot/initramfs.img
}
EOF

grub-mkrescue -o amnesia-os.iso isoroot
```

## Release

Tag the release and attach the ISO:

```bash
git tag v0.1.0
git push origin v0.1.0
```