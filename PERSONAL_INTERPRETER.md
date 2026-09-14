# Personal Interpreter Audio Bridge

This repository builds the optional `Personal Interpreter Mic` CoreAudio
loopback device used by the Personal Interpreter macOS application. It is
distributed separately from the Mac App Store application.

The driver is derived from BlackHole and remains licensed under GNU GPLv3.
The original copyright and license are preserved in `LICENSE`. Personal
Interpreter releases must include the corresponding source code. BlackHole
branding and compiled binaries are not redistributed.

## Build

Install the Developer ID Application certificate, configure a notarytool
keychain profile, then run:

```zsh
PI_APPLICATION_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
PI_NOTARY_PROFILE="personal-interpreter-notary" \
  ./Scripts/build_personal_interpreter_bridge.sh
```

The resulting ZIP contains a signed, notarized installer application. The
installer writes only the driver bundle to `/Library/Audio/Plug-Ins/HAL` and
restarts CoreAudio so the microphone appears without a Mac reboot.
