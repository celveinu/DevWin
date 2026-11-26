#!/usr/bin/env bash
# DevWin ISO builder. Run on a Debian 12/13 machine (or VM / cloud server) with ~30 GB free disk,
# 8 GB RAM and internet access. Needs root. Ubuntu hosts can fail because their debootstrap may
# not know the "trixie" release.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./build.sh" >&2
  exit 1
fi

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing build tools"
apt-get update
apt-get install -y live-build debootstrap debian-archive-keyring squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin syslinux syslinux-common isolinux dosfstools mtools cpio git

WORK=/var/tmp/devwin-build
rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"

# Keep a copy of the build log next to the kit even if the build fails (CI uploads it).
trap 'cp -f "$WORK/build.log" "$HERE/build.log" 2>/dev/null || true' EXIT

echo "==> Configuring live-build (Debian 13 'trixie', amd64, hybrid ISO)"
lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debian-installer none \
  --binary-images iso-hybrid \
  --bootloaders "grub-efi,syslinux" \
  --iso-application "DevWin" \
  --iso-volume "DEVWIN" \
  --linux-flavours amd64 \
  --apt-recommends true \
  --bootappend-live "boot=live components quiet splash username=devwin hostname=devwin" \
  --memtest none

echo "==> Copying package lists, hooks and overlay files"
cp -r "$HERE/config/." "$WORK/config/"
# Uploading through a website or Windows can drop the executable bit, so set it here.
chmod +x "$WORK"/config/hooks/live/*.hook.chroot
chmod +x "$WORK"/config/includes.chroot/usr/local/bin/*

echo "==> Building ISO (this takes a while)"
lb build 2>&1 | tee "$WORK/build.log"

ISO="$(ls "$WORK"/*.iso | head -n1)"
mv "$ISO" "$HERE/devwin-amd64.iso"
( cd "$HERE" && sha256sum devwin-amd64.iso | tee devwin-amd64.iso.sha256 )
echo "==> Done: $HERE/devwin-amd64.iso"
echo "Test it in a VM first (QEMU/VirtualBox, UEFI on), then write to USB with balenaEtcher or dd."
