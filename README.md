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
two channels at 44.1 and 48 kHz. A public installer release still requires a
Developer ID Installer certificate, Apple notarization, and release validation.
Never distribute an unsigned package to end users.

## Building a release

```zsh
PI_INSTALLER_IDENTITY="Developer ID Installer: Your Name (TEAMID)" \
  ./Scripts/build_personal_interpreter_bridge.sh
```

Then notarize and staple the resulting package before attaching it to a GitHub
release. Users select `Personal Interpreter Mic` as the microphone inside their
calling application.

## License and attribution

This driver is based on the open-source
[BlackHole](https://github.com/ExistentialAudio/BlackHole) CoreAudio driver by
Existential Audio Inc. The derivative driver source remains licensed under GNU
GPLv3; see `LICENSE`. Corresponding source must be published with every binary
release. BlackHole trademarks, artwork, and official binaries are not used by
Personal Interpreter builds. The original upstream documentation is retained in
`UPSTREAM_README.md` for attribution and engineering reference.
