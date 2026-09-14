# Personal Interpreter Audio Bridge

`Personal Interpreter Mic` is the optional universal macOS audio device for
Personal Interpreter. It lets the translator send synthesized speech to any
application that accepts a system microphone, including Google Meet, Zoom,
Microsoft Teams, Slack Huddles, Discord, browser calls, and recording tools.

The Mac App Store application works without this package through supported
connectors and local captions. Install Audio Bridge only when universal
microphone compatibility is needed.

## Status

The driver builds as a universal `arm64` + `x86_64` CoreAudio bundle and exposes
two channels at 44.1 and 48 kHz. It is bundled in a small installer application,
so releases need a Developer ID Application certificate and Apple notarization;
a separate Developer ID Installer certificate is not required. Never distribute
an unsigned or unnotarized build to end users.

## Building a release

```zsh
PI_APPLICATION_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
  PI_NOTARY_PROFILE="personal-interpreter-notary" \
  ./Scripts/build_personal_interpreter_bridge.sh
```

The script signs, notarizes and staples the installer app before creating the
release ZIP. When opened, the installer asks for administrator authorization
once and installs only the audio driver. Users then select
`Personal Interpreter Mic` as the microphone inside their calling application.

## License and attribution

This driver is based on the open-source
[BlackHole](https://github.com/ExistentialAudio/BlackHole) CoreAudio driver by
Existential Audio Inc. The derivative driver source remains licensed under GNU
GPLv3; see `LICENSE`. Corresponding source must be published with every binary
release. BlackHole trademarks, artwork, and official binaries are not used by
Personal Interpreter builds. The original upstream documentation is retained in
`UPSTREAM_README.md` for attribution and engineering reference.
