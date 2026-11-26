# DevWin: a Windows 11-style Linux OS for developers

**Built by Tech Lo Tech Hub.**

DevWin is a build kit for a bootable ISO. The base is **Debian 13 (trixie)** with the stock Linux kernel and **KDE Plasma 6 on Wayland**, themed to look and behave like Windows 11 with a glass (blur and translucency) finish. **Waydroid** runs Android apps. Developer tools come preinstalled.

> **Status: untested.** This kit was written without access to Debian's package mirrors or a way to boot the result. No ISO has been built or booted. Expect to fix a few package names or theme details on the first run, and test in a VM before real hardware.

## What you need to build

- A **Debian 12 or 13** machine, VM or cloud server (x86_64). Ubuntu hosts may fail because their debootstrap can lack the trixie script.
- 8 GB RAM, 30 GB free disk, internet, root access

## Build

```bash
unzip devwin.zip && cd devwin
chmod +x build.sh
sudo ./build.sh
```

The result is `devwin-amd64.iso` and a `.sha256` file. Expect 30-90 minutes. The full log is in `/var/tmp/devwin-build/build.log`.

**If the build stops with `E: Unable to locate package X`:** that package name does not exist in trixie. Delete or fix that line in `config/package-lists/devwin.list.chroot` and run again. One bad name stops the whole build, and I could not check every name from where I wrote this.

Steps in the hooks only log `WARN:` lines on failure and do not stop the build. Search the log for `WARN` after a build to see what was skipped (themes, VS Code, Waydroid, boot splash, rounded corners).

## Test

1. Boot the ISO in QEMU or VirtualBox with **UEFI on** and at least 4 GB RAM.
2. The live session logs in as `devwin`, password `live` (live-config's default). The live user has passwordless sudo.
3. On first login `devwin-apply-look` waits for the desktop, then builds the taskbar and applies the theme. If it fails it retries at the next login.
4. Run `devwin-android-setup` in a terminal to enable Android apps.

## Built-in manual and help (inside the OS)

- **DevWin Manual** and **DevWin Troubleshooting** appear in the Start menu (and the manual has a desktop icon). They open an offline page at `/usr/share/doc/devwin/manual.html`, which works with no internet. Markdown sources: `manual.md` and `troubleshooting.md` in the same folder.
- `devwin-help` opens the manual, `devwin-help fix` opens the troubleshooting guide, and `devwin-help --text` reads it in a terminal.
- `devwin-doctor` checks the desktop, memory, disk, network, Android, Wine, VS Code, Docker and KVM, and suggests a fix for each problem. `devwin-doctor --fix` offers safe one-step fixes. `devwin-doctor --report` writes `~/devwin-report.txt` for support requests.
- A one-time welcome notice points new users to the manual.
- **Branding:** "Built by Tech Lo Tech Hub" appears in the manual, login screen text, terminal welcome message, `/etc/devwin-release`, the About page of System Settings and the welcome notice. The branding hook (`0300-devwin-branding.hook.chroot`) also sets the name in `/etc/os-release`. The "Built by" line in System Settings depends on a KDE file I could not check, so confirm it on first boot.
- **If you edit `manual.md` or `troubleshooting.md`,** regenerate `manual.html`, because the HTML is a separate file. Pandoc or Python's `markdown` package can do it. The page expects the headings `devwin-user-manual` and `troubleshooting-guide`.
- The manual says support requests go to Tech Lo Tech Hub but gives no contact address, because I don't have one. Add your email or website to section 11 of `manual.md` and to the end of `troubleshooting.md`.

## Android apps

- Waydroid needs a **Wayland** session and a kernel with binder (`CONFIG_ANDROID_BINDER_IPC` / binderfs). Debian's stock kernel normally has this; verify with `grep binder /proc/filesystems`.
- Install an APK: `waydroid app install app.apk`
- Google Play login needs the device registered with Google (the setup script prints the steps).
- Apps that need ARM-only code may not run on x86 PCs without a translation layer (for example via the community `waydroid_script` project).
- Waydroid is heavy. Under 4 GB RAM expect it to be slow.

## Windows apps

- **Wine** (with winetricks and Vulkan support) is preinstalled, plus 32-bit Wine support added during the build. Double-clicking a `.exe` or `.msi` opens it with Wine, and installed programs appear in the Start menu.
- **Bottles** (a friendlier Wine manager with per-app settings) is optional: `devwin-install-devtools bottles`.
- Wine is a compatibility layer, not Windows. Many apps run well (classic desktop programs, many games, Notepad++, 7-Zip). Expect problems with Microsoft Office 365, Adobe Creative Cloud, apps with kernel-level DRM or anti-cheat, and anything that needs Windows drivers.
- For apps Wine cannot run, use a real Windows VM. QEMU/KVM and virt-manager are preinstalled, but you must supply your own Windows ISO and license.
- If `WARN: wine32` appears in the build log, 32-bit Windows apps may fail until you run `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install wine32:i386`.

## Glass look

Applied at first login by `devwin-apply-look`: blurred translucent taskbar, menus and popups, wobbly windows, genie minimize, smooth fades, translucent Qt apps through Kvantum, a semi-transparent Konsole, and the "DevWin Aurora" wallpaper. A Plymouth boot splash with a pulsing orb is included.

Limits:

- It is blur and transparency, not real-time refraction like Apple's liquid glass.
- **Rounded corners:** [KDE-Rounded-Corners](https://github.com/matinlotfali/KDE-Rounded-Corners) is built into the image but **not enabled automatically**, because it is compiled against whatever KWin version Debian ships and a mismatch can misbehave. Enable it in System Settings > Window Management > Desktop Effects after you confirm it loads. If the build failed you will see `WARN: rounded-corner` in the log.
- Blur and wobbly windows need GPU compositing. On very old graphics, turn them off in Desktop Effects.
- Theme names can differ between versions of the Fluent themes; the script looks them up by name and skips what it cannot find.

## Developer toolset

**Preinstalled, system development:** GCC, clang/LLVM/lld/lldb, ccache, CMake, Ninja, Meson, autotools, nasm, gdb (plus multiarch), valgrind, strace, ltrace, perf, bpftrace, tcpdump, Wireshark, nmap, ctags, cscope, sparse; kernel build prerequisites (headers, flex, bison, libelf, libssl, dwarves); cross-compilers for ARM and AArch64 and bare-metal ARM, OpenOCD, `qemu-user-static`; and OS/package tooling (`live-build`, `debootstrap`, `xorriso`, `devscripts`, `debhelper`, QEMU, OVMF) so DevWin can rebuild itself.

**Preinstalled, app development:** Python, Node/npm, Go, Rust, Java with Maven and Gradle, PHP and Composer, Ruby; Qt 6 with Qt Creator, GTK 3/4 and libadwaita, SDL2; Docker, Podman, QEMU/virt-manager; VS Code, Neovim; MariaDB, Redis, PostgreSQL and SQLite clients; GitHub CLI and git-lfs; JetBrains Mono and Fira Code fonts; adb and fastboot.

**VS Code for Python, C and C++:**

- VS Code is installed from Microsoft's official apt repo during the build (`0100-devwin-apps.hook.chroot`). If that download fails the build logs `WARN: VS Code not installed`; install it later with `devwin-install-devtools vscode` (Flatpak).
- At first login `devwin-vscode-setup` installs these extensions (needs internet; retries at next login until it succeeds): Python, Pylance, debugpy, Ruff, C/C++ (cpptools), CMake Tools, Makefile Tools, CMake language support. Run `devwin-vscode-setup --force` to repeat.
- Default settings are in `/etc/skel/.config/Code/User/settings.json`: JetBrains Mono with ligatures, format on save, Ruff for Python, g++ with C17/C++20 and clang-tidy for C/C++, CMake with Ninja, telemetry off. VS Code also starts in native Wayland mode.
- Python tools: Python 3, pip, venv, pipx, `python-is-python3`, pytest, pylint, flake8, mypy, black, IPython. C/C++ tools: gcc/g++, clang, clangd, clang-format, clang-tidy, cppcheck, bear, gdb, valgrind, CMake, Ninja, Doxygen, GoogleTest.
- Pylance and the C/C++ extension only work in Microsoft's build of VS Code, which is what this installs. They would not work in open-source builds such as VSCodium.

**Installed on demand with `devwin-install-devtools`** (these are large or update often, so they are not baked into the ISO): Node via fnm, rustup, SDKMAN (Kotlin, Gradle, JDKs), pyenv, .NET SDK, Flutter, Android Studio, DBeaver, Postman and Insomnia. They go into your home folder or Flatpak and need internet.

System tweaks for development: higher file-watcher limit (`fs.inotify.max_user_watches`), the live user is in the `docker`, `libvirt` and `kvm` groups.

Not included: iOS/macOS development (needs Apple tools), commercial JetBrains IDEs (install through JetBrains Toolbox), and game engines such as Unity or Unreal.

The extra packages add roughly 2-4 GB to the ISO. If you want it lighter, delete the "System development" and "App development" blocks you do not need from `config/package-lists/devwin.list.chroot`.

## Low-hardware tuning

- zram swap (zstd, 60% of RAM), `vm.swappiness=150`, `earlyoom`
- The build uses `--apt-recommends true` for reliability on the first build (a missing "recommended" desktop component is a common source of a broken desktop). For a leaner image, switch it back to `false` in `build.sh`, then add back any desktop packages that turn out to be missing.
- TLP and preload are left out on purpose: TLP conflicts with Plasma's power-profiles-daemon.
- To go lighter, replace `kde-plasma-desktop` with `plasma-desktop` and drop LibreOffice from the package list.

## Customize

- Packages: `config/package-lists/devwin.list.chroot`
- Theme, taskbar and effects: `config/includes.chroot/usr/local/bin/devwin-apply-look`
- Build-time installs (Waydroid, VS Code, themes): `config/hooks/live/0100-devwin-apps.hook.chroot`
- Boot splash and rounded corners: `config/hooks/live/0200-devwin-polish.hook.chroot`
- Live user and hostname: `config/includes.chroot/etc/live/config.conf.d/devwin.conf`
- Wallpaper and splash images: `config/includes.chroot/usr/share/wallpapers/DevWin/` and `.../plymouth/themes/devwin/`

## Known rough edges

- Not verifiable without a build: package names, Fluent theme names and install options, whether live-config's autologin works with SDDM on this setup, whether Calamares's install-time cleanup removes the live user cleanly.
- Secure Boot is not configured; disable it in firmware for first tests.
- Fluent theme installers and the Waydroid repo can change; the hook logs a warning instead of failing.
- Branding is generic; replace the logo, wallpaper and splash to make it your own.
