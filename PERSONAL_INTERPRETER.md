# Personal Interpreter Audio Bridge

This repository builds the optional `Personal Interpreter Mic` CoreAudio
loopback device used by the Personal Interpreter macOS application. It is
distributed separately from the Mac App Store application.

The driver is derived from BlackHole and remains licensed under GNU GPLv3.
The original copyright and license are preserved in `LICENSE`. Personal
Interpreter releases must include the corresponding source code. BlackHole
branding and compiled binaries are not redistributed.

## Build

Install the Developer ID Application and Developer ID Installer certificates,
then run:

```zsh
PI_INSTALLER_IDENTITY="Developer ID Installer: Your Name (TEAMID)" \
  ./Scripts/build_personal_interpreter_bridge.sh
```

The resulting package must be notarized and stapled before publication. The
installer writes only the driver bundle to `/Library/Audio/Plug-Ins/HAL`.
