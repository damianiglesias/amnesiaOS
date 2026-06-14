# AmnesiaOS Architecture

## Overview

AmnesiaOS is built around a single core principle: **the operating system must leave no trace after shutdown**. This is achieved by loading the entire system into RAM at boot time.

## Boot sequence
BIOS/UEFI

│

▼

GRUB 2.12

│  loads kernel + initramfs into RAM

▼

Linux Kernel 6.16.1

│  decompresses initramfs into tmpfs

▼

/init (shell script)

│  mounts proc, sysfs, devtmpfs

▼

BusyBox shell

│  full interactive environment

▼

[ shutdown ]

│

▼

RAM cleared — no trace remains
## Components

### Kernel
Linux 6.16.1 compiled from source with a minimal configuration focused on:
- initramfs/initrd support
- tmpfs (RAM filesystem)
- USB storage drivers
- ext4 filesystem support
- SquashFS support (for future compressed system image)

### Initramfs
A small CPIO archive compressed with gzip that contains:
- BusyBox 1.35.0 (static binary, ~1MB)
- Symlinks for common utilities
- `/init` script that bootstraps the system

The initramfs is loaded entirely into RAM by the kernel before execution begins.

### Init script
A minimal shell script that:
1. Mounts virtual filesystems (`proc`, `sysfs`, `devtmpfs`)
2. Launches an interactive shell

### BusyBox
A single static binary providing over 300 Unix utilities including:
`sh`, `ls`, `cat`, `mount`, `ip`, `ping`, `vi`, `tar`, `grep`, and more.

Being statically linked, BusyBox requires no external libraries.

## RAM layout at runtime
Physical RAM

┌─────────────────────────┐

│   Linux Kernel          │  ~15MB

├─────────────────────────┤

│   Initramfs (tmpfs)     │  ~10MB

├─────────────────────────┤

│   Free for use          │  remaining RAM

└─────────────────────────┘
## Why no disk writes?

- The kernel mounts everything as `tmpfs` (RAM-backed)
- No swap partition is configured
- No persistent storage is mounted by default
- On shutdown, RAM is cleared by the hardware power cycle

## Future: Full RAM system

Planned for v1.0.0:
1. A SquashFS image containing the full LFS userland is stored on USB
2. At boot, it is copied entirely into RAM (`tmpfs`)
3. `pivot_root` switches the root filesystem to RAM
4. The USB is unmounted
5. The system runs with zero disk dependency