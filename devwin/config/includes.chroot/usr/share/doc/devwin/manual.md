# DevWin User Manual

*Version 0.1 · Built by Tech Lo Tech Hub*

## 1. Welcome

DevWin is a desktop operating system made for developers and programmers. It looks and feels like Windows 11 with a glass finish, runs **Android apps** and **Windows apps**, and comes with tools for **system development** and **app development** ready to use.

DevWin is built by **Tech Lo Tech Hub**. Under the hood it uses the Linux kernel, Debian GNU/Linux 13 and the KDE Plasma desktop.

If something goes wrong, open **DevWin Manual** from the Start menu and go to the Troubleshooting guide, or run `devwin-doctor` in a terminal.

## 2. Getting started

### Starting from a USB stick

1. Plug in the USB stick and restart the computer.
2. Open the boot menu (usually F12, F10, F9, Esc or Del, depending on the computer) and choose the USB stick. Choose the **UEFI** entry if there are two.
3. If it will not start, turn off **Secure Boot** in the firmware settings and try again.

The live session logs in automatically as the user `devwin`. If you are ever asked for a password, it is `live`. In the live session, nothing you change is kept after a restart.

### Installing to the disk

1. Open the installer from the desktop or the Start menu (it is called **Install Debian** or **Install System**).
2. Follow the steps: language, location, keyboard, disk and your user account.
3. **Back up your files first.** Choosing to erase the disk deletes everything on it.
4. When it finishes, restart and remove the USB stick.

### Your first login

The first time you sign in, DevWin sets up your taskbar, theme and wallpaper. This can take up to a minute. If you are online, it also installs the VS Code extensions for Python, C and C++ in the background.

## 3. The desktop

- **Taskbar:** at the bottom and centered. From the left: the **Start** button, your pinned and open apps, then the tray (network, sound, battery, notifications) and the clock.
- **Start menu:** press the Start button or the Windows key, then just start typing to search for an app or a file.
- **Wallpaper and look:** right-click the desktop and choose the configure option, or open **System Settings**.
- **System Settings:** open it from the Start menu to change Wi-Fi, display, sound, power, keyboard, mouse and language.

### Keyboard shortcuts

These are KDE's defaults. You can change them in System Settings, under Keyboard, then Shortcuts.

| Keys | What it does |
|---|---|
| Windows key (Meta) | Open the Start menu |
| Alt + Tab | Switch between windows |
| Meta + D | Show the desktop |
| Meta + W | Overview of all windows |
| Meta + Left / Right | Snap a window to the left or right half |
| Meta + Up | Maximize the window |
| Meta + L | Lock the screen |
| Print Screen | Take a screenshot |
| Alt + F4 | Close the window |

## 4. Everyday setup

- **Wi-Fi:** click the network icon in the tray, pick your network and enter the password.
- **Bluetooth:** open System Settings, then Bluetooth, and pair your device.
- **Sound:** click the speaker icon in the tray to change volume and choose the output device.
- **Screen size and sharpness:** System Settings, then Display. On high-resolution screens, increase the **Scale**.
- **Screenshots:** press Print Screen to open the screenshot tool.
- **Printing:** printing is not set up by default. To add it, open a terminal and run `sudo apt install cups print-manager`.

## 5. Installing and updating software

- **Discover:** open **Discover** from the Start menu to find and install apps from Flatpak and Debian.
- **Terminal:** `sudo apt update`, then `sudo apt install <package-name>`. To search, use `apt search <word>`.
- **Flatpak apps:** if Flathub is not set up yet, run `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`, then `flatpak install flathub <app-id>`.
- **Remove an app:** `sudo apt remove <package-name>`.
- **Update everything:** `sudo apt update && sudo apt full-upgrade`, then `flatpak update`. Restart afterwards if the kernel was updated. Back up important files first.

## 6. Android apps

DevWin runs Android apps with **Waydroid**.

**One-time setup**

1. Sign in with the **Plasma (Wayland)** session. You can pick the session at the bottom of the login screen.
2. Open a terminal and run `devwin-android-setup`. It downloads the Android system, which is a large download (about 1 GB or more), so use a good connection.
3. When it finishes, Android opens in a window.

**Using Android apps**

- Installed Android apps appear in the Start menu like any other app.
- To install an APK file: `waydroid app install file.apk`.
- To see installed Android apps: `waydroid app list`.
- To open the full Android screen: `waydroid show-full-ui`.
- To free memory when you are not using Android: `waydroid session stop`.

**Google Play:** to sign in to the Play Store, the device must be registered with Google. `devwin-android-setup` prints the steps at the end. The registration can take a while to take effect.

**Good to know:** Android apps need more memory (4 GB of RAM or more is recommended). Apps that only work on ARM processors may not run on a PC.

## 7. Windows apps

DevWin runs Windows apps with **Wine**.

- Double-click a `.exe` or `.msi` file to open it with Wine. Installed Windows apps appear in the Start menu.
- **Bottles** is an optional app that makes Wine easier, with a separate setup for each app. Install it with `devwin-install-devtools bottles`.
- Many classic desktop programs and many games work well. Wine is a compatibility layer and not Windows itself, so some apps do not work. These include Microsoft Office 365, Adobe Creative Cloud, apps with kernel-level copy protection or anti-cheat, and programs that need Windows drivers.
- For apps Wine cannot run, use a real Windows virtual machine. DevWin includes **virt-manager**, but you need your own Windows installation file and license.

## 8. For developers

**What is included**

- **Languages:** Python, C, C++, Rust, Go, Java, Node.js, PHP and Ruby.
- **Build tools:** GCC, clang, CMake, Ninja, Meson, make, ccache.
- **Debugging and analysis:** gdb, lldb, valgrind, strace, perf, Wireshark.
- **Kernel, embedded and OS work:** kernel build tools, ARM cross-compilers, OpenOCD, live-build and QEMU.
- **Containers and virtual machines:** Docker, Podman, QEMU and virt-manager.
- **Other tools:** git, GitHub CLI, Neovim, tmux, zsh, adb and fastboot.

**VS Code** is in the Start menu. The Python, C/C++ and CMake extensions install on first login. To run that again: `devwin-vscode-setup --force`.

**Quick starts**

```
# C++
mkdir hello && cd hello
printf '#include <iostream>\nint main(){ std::cout << "Hello from DevWin\\n"; }\n' > main.cpp
g++ -std=c++20 -Wall -o hello main.cpp && ./hello

# Python
python3 -m venv .venv
source .venv/bin/activate
pip install requests
```

**Docker:** `docker run hello-world`. If you get "permission denied", run `sudo usermod -aG docker $USER`, then sign out and back in.

**More tools on demand:** run `devwin-install-devtools` to install Node via fnm, Rust via rustup, Kotlin and Gradle via SDKMAN, pyenv, the .NET SDK, Flutter, Android Studio, DBeaver, Postman and Insomnia. They install into your home folder or as Flatpaks.

**Virtual machines:** virtualization must be turned on in the computer's firmware (often called Intel VT-x, AMD-V or SVM).

## 9. Appearance and performance

- **Glass effects (blur, transparency, wobbly windows):** if the computer feels slow, turn them off in System Settings, under Window Management, then Desktop Effects.
- **Re-apply the DevWin look:** run `devwin-doctor --fix` and choose the first option.
- **Rounded window corners:** the effect is installed but off by default. You can try it in Desktop Effects.
- **Tips for older computers:**
  - Turn off the glass effects.
  - Close Android (`waydroid session stop`) when you are not using it.
  - Turn off file indexing in System Settings, under Search, then File Search.
  - Use `btop` in a terminal to see what is using memory and CPU.
  - DevWin uses compressed memory (zram) and an out-of-memory guard (earlyoom) to stay responsive on low memory.

## 10. Keeping your data safe

- Copy your Documents and project folders to an external drive or cloud storage regularly.
- For system snapshots you can install Timeshift: `sudo apt install timeshift`.
- Back up before big updates and before changing disk partitions.

## 11. Getting help

- `devwin-help`: opens this manual. `devwin-help fix` opens the Troubleshooting guide. `devwin-help --text` shows the manual in the terminal.
- `devwin-doctor`: checks your system for common problems and suggests fixes.
- `devwin-doctor --fix`: offers safe one-step fixes (re-apply the look, restart the desktop, sound or Android, turn glass effects on or off).
- `devwin-doctor --report`: saves a report file called `devwin-report.txt` in your home folder. Send it to Tech Lo Tech Hub when asking for support.

## 12. About, credits and legal

**DevWin 0.1** is built by **Tech Lo Tech Hub**.

DevWin is made from many open-source projects, including Debian GNU/Linux, the Linux kernel, KDE Plasma, Waydroid, Wine, the Fluent themes and many others. Each is provided under its own license, which you can read in `/usr/share/doc/<package-name>/copyright`. The software is provided as is, without warranty, as described in those licenses.

**Trademarks:** Windows, Microsoft and Office are trademarks of Microsoft Corporation. Android and Google Play are trademarks of Google LLC. Debian is a registered trademark of Software in the Public Interest, Inc. Linux is a trademark of Linus Torvalds. DevWin is not affiliated with or endorsed by any of them. DevWin's Windows-like appearance comes from open-source themes, and DevWin contains no Windows code.
