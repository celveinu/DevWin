# Troubleshooting Guide

*DevWin 0.1 · Built by Tech Lo Tech Hub*

**Start here:** open a terminal and run `devwin-doctor`. It checks the most common problems and tells you what to try. For one-step fixes run `devwin-doctor --fix`. If you need to ask for help, run `devwin-doctor --report` and send the file `devwin-report.txt` from your home folder.

Commands that start with `sudo` ask for your password. Copy commands one at a time and read any message that appears.

## Starting up and installing

### The USB stick will not start

- Open the boot menu and choose the **UEFI** entry for the USB stick.
- Turn off **Secure Boot** in the firmware settings.
- Write the USB stick again with a tool like balenaEtcher, and try a different USB port.
- Check that the file was not damaged in the download: `sha256sum -c devwin-amd64.iso.sha256`. It should say OK.

### Black screen or a frozen picture at start

Graphics drivers are the usual cause. At the boot menu, highlight the first entry and press **e**, add the word `nomodeset` at the end of the line that starts with `linux`, then press **F10** to start. If that works, install the right driver after you log in.

- **NVIDIA graphics:** `sudo apt install nvidia-driver`, then restart. If apt cannot find it, enable the `non-free` section in `/etc/apt/sources.list` and run `sudo apt update`.
- **AMD and Intel graphics:** `sudo apt update && sudo apt full-upgrade`, then restart.

### The installer fails

- Check that the disk has enough free space and is not damaged.
- Do not remove the USB stick during installation.
- The installer keeps a log called `session.log` under the `.cache/calamares` folder of the user who ran it. Include it when asking for help.

### The clock is wrong when you dual boot with Windows

Run `timedatectl set-local-rtc 1 --adjust-system-clock`.

### I forgot my password

In the live session the password is `live`. On an installed system: restart, hold Shift (or press Esc) to open the boot menu, choose **Advanced options**, then the **recovery mode** entry, then **root shell**. Run `mount -o remount,rw /`, then `passwd your-username`, and restart.

## Desktop and look

### The taskbar or theme looks like plain KDE

The look is applied once, a little after your first login, and it can take up to a minute. If it still looks wrong:

1. Run `devwin-doctor --fix` and choose **Re-apply the DevWin look**.
2. If the desktop is broken after login: press Ctrl + Alt + F3 and sign in, run `mv ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasma-org.kde.plasma.desktop-appletsrc.bak`, then restart. After the desktop loads, run `devwin-doctor --fix` and re-apply the look.

### The desktop is slow or choppy

- Turn off glass effects: `devwin-doctor --fix`, then choose the option to turn them off.
- See what is using memory and CPU: run `btop`.
- Close Android when you are not using it: `waydroid session stop`.
- Turn off file indexing: System Settings, then Search, then File Search.
- Make sure the Plasma (Wayland) session and your graphics driver are working: run `devwin-doctor`.

### The screen flickers, or windows have strange edges

Turn off blur and rounded corners: System Settings, then Window Management, then Desktop Effects. Or run:

```
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure
```

### The computer freezes or runs out of memory

- Run `free -h` to see how much memory is free.
- Close apps you are not using, especially Android (`waydroid session stop`), virtual machines and browser tabs.
- DevWin has an out-of-memory guard: `systemctl status earlyoom`. If an app was closed on its own, this is why.
- Use `zramctl` to check that compressed memory is on.

## Network, sound and Bluetooth

### Wi-Fi does not work

1. Run `nmcli device status` and `rfkill list`. If something is blocked, run `sudo rfkill unblock all`.
2. Some Wi-Fi adapters need extra firmware. Run `sudo dmesg | grep -i firmware` to see which is missing, then install it, for example `sudo apt install firmware-brcm80211` for many Broadcom adapters.
3. Restart the network service: `sudo systemctl restart NetworkManager`.
4. Connecting with a cable or a phone's USB tethering helps you download missing firmware.

### There is no sound

- Click the speaker icon in the tray and check the volume and the **output device**.
- Restart the sound system: `systemctl --user restart pipewire pipewire-pulse wireplumber` (or `devwin-doctor --fix`).

### Bluetooth does not work

Run `sudo systemctl enable --now bluetooth` and `sudo rfkill unblock bluetooth`, then pair the device again in System Settings.

## Software and updates

### apt shows errors

Try these in order:

```
sudo apt update --fix-missing
sudo dpkg --configure -a
sudo apt -f install
sudo apt full-upgrade
```

"Could not get lock" means another update is running (for example Discover). Wait for it to finish. Do not delete lock files.

### The disk is full

- Check: `df -h`.
- Clean up: `sudo apt clean`, `sudo apt autoremove`, `flatpak uninstall --unused`.
- Free Docker space: `docker system prune` (this removes unused containers and images).
- Shrink system logs: `sudo journalctl --vacuum-size=200M`.

## Android apps

First run `devwin-doctor`, which checks the points below.

### Android will not start

1. Use the **Plasma (Wayland)** session (choose it at the bottom of the login screen). Waydroid does not work in the X11 session.
2. Check that the kernel supports Android: `grep binder /proc/filesystems`. If it prints nothing, this kernel cannot run Android apps.
3. Restart it:
   ```
   waydroid session stop
   sudo systemctl restart waydroid-container
   waydroid session start
   waydroid show-full-ui
   ```
4. If it still fails, run `waydroid log` and include the output when asking for help.

### Android has no internet

Docker or a firewall can block Waydroid's network. Restart it with `sudo systemctl restart waydroid-container` (restart it again after Docker starts). If that does not help, see the Waydroid documentation at docs.waydro.id.

### Google Play says the device is not certified

Register the device with Google. `devwin-android-setup` prints the steps. It can take a while to take effect.

### An Android app crashes or will not install

Some apps only work on ARM processors. Try another version of the app, or use its web version.

### Start Android again from scratch

**Warning: this deletes all Android apps and data.**

```
waydroid session stop
sudo systemctl stop waydroid-container
sudo rm -rf /var/lib/waydroid ~/.local/share/waydroid
devwin-android-setup
```

## Windows apps

### A .exe file will not open or the app crashes

1. Check that Wine is installed: `wine --version`.
2. Run the app from a terminal to see error messages: `wine path/to/app.exe`.
3. Many apps need extra Windows components. Try `winetricks` (for example `winetricks corefonts vcrun2022`).
4. Try **Bottles** (`devwin-install-devtools bottles`) with a separate setup per app.
5. If a 32-bit app fails and you see a message about `wine32`: `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install wine32:i386`.
6. If Wine still cannot run the app, use a Windows virtual machine with virt-manager.

### Start the default Wine setup again

**Warning: this deletes Windows apps installed in the default Wine folder.** Run `rm -rf ~/.wine`.

## Developer tools

### VS Code is missing or its extensions are missing

- Not installed: run `devwin-install-devtools vscode`.
- No extensions: connect to the internet and run `devwin-vscode-setup --force`.
- Blank or flickering window: run `code --disable-gpu`.
- Reset VS Code settings (your extensions stay): move `~/.config/Code/User/settings.json` away and restart VS Code.

### Docker says "permission denied" or "cannot connect to the daemon"

- Permission: `sudo usermod -aG docker $USER`, then sign out and back in.
- Daemon not running: `sudo systemctl enable --now docker`.

### Virtual machines say KVM is not available

- Turn on virtualization in the computer's firmware (Intel VT-x, AMD-V or SVM).
- Check: `ls /dev/kvm`.
- Add yourself to the groups: `sudo usermod -aG kvm,libvirt $USER`, sign out and back in, and run `sudo systemctl enable --now libvirtd`.

## Still stuck?

1. Run `devwin-doctor --report`.
2. Send the file `devwin-report.txt` from your home folder to Tech Lo Tech Hub, with a short description of what happened and what you tried.
