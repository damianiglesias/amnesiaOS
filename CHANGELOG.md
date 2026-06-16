# Changelog

All notable changes to AmnesiaOS will be documented here.

Format: `[version] - date`

---

## [0.1.0] - 2026-06-14

### Added
- Initial release
- Linux kernel 6.16.1 compiled from source
- Custom initramfs with BusyBox 1.35.0
- Full RAM boot — system runs entirely in memory
- Basic shell environment with common utilities
- GRUB bootloader support (BIOS + EFI)
- Bootable ISO image

### System components
- Kernel: Linux 6.16.1
- Init system: custom shell script
- Userland: BusyBox 1.35.0
- Bootloader: GRUB 2.12
- Filesystem: tmpfs (RAM)

---

## Versioning

- `0.x.x` — Early development
- `1.x.x` — Stable release with persistent USB support
- `2.x.x` — Full LFS userland in RAM

## [0.2.0] - 2026-06-16

### Added
- Automatic network configuration at boot (DHCP)
- DNS resolution support via dynamic resolv.conf
- udhcpc integration with custom configuration script
- Additional BusyBox utilities (basename, udhcpc)

### Fixed
- Shell no longer exits unexpectedly, causing kernel panic
- Console output properly bound to tty1

### System components
- Kernel: Linux 6.16.1
- Init system: custom shell script with network bootstrap
- Userland: BusyBox 1.35.0
- Bootloader: GRUB 2.12
- Filesystem: tmpfs (RAM)
- Network: DHCP client (udhcpc)