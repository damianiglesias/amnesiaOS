# Roadmap

## v0.1.0 — Current
- [x] Linux kernel 6.16.1 compiled from source
- [x] Custom initramfs with BusyBox
- [x] Full RAM boot
- [x] Bootable ISO
- [x] Basic shell environment

## v0.2.0 — Improved shell environment
- [ ] Network configuration at boot
- [ ] More BusyBox utilities enabled
- [ ] Basic `/etc` configuration (hostname, hosts, resolv.conf)
- [ ] Custom boot message / splash
- [ ] Keyboard layout selection

## v0.3.0 — Persistence option
- [ ] Optional encrypted persistence layer on USB
- [ ] Save/restore user files to encrypted partition
- [ ] Works alongside the RAM-only mode

## v0.4.0 — Networking
- [ ] DHCP client at boot
- [ ] SSH server (dropbear)
- [ ] Basic firewall rules
- [ ] Wi-Fi support

## v1.0.0 — Full LFS userland in RAM
- [ ] Complete LFS system loaded into RAM via SquashFS
- [ ] pivot_root to full RAM filesystem
- [ ] USB fully unmounted after boot
- [ ] GCC, Python, Perl available in RAM
- [ ] Package manager (minimal)

## v2.0.0 — Security focused
- [ ] Kernel hardening (grsecurity patches)
- [ ] Memory encryption
- [ ] Secure boot support
- [ ] Automatic RAM wipe on shutdown
- [ ] Tor network integration