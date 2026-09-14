#!/bin/zsh
set -euo pipefail

bridge_root="${0:A:h:h}"
bridge_build="$bridge_root/build-personal-interpreter"
bridge_name="Personal Interpreter Mic"
bridge_bundle_id="com.interpreter.PersonalInterpreter.AudioBridge"
installer_name="Personal Interpreter Mic Installer"
bridge_version="$(<"$bridge_root/VERSION")"
application_identity="${PI_APPLICATION_IDENTITY:-Developer ID Application: Nataliya Tkachova (4YDWLX6Y9Y)}"

rm -rf "$bridge_build"
mkdir -p "$bridge_build/products"

xcodebuild \
  -project "$bridge_root/BlackHole.xcodeproj" \
  -configuration Release \
  -target BlackHole \
  CONFIGURATION_BUILD_DIR="$bridge_build/products" \
  MACOSX_DEPLOYMENT_TARGET=14.0 \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  PRODUCT_BUNDLE_IDENTIFIER="$bridge_bundle_id" \
  CODE_SIGNING_ALLOWED=NO \
  build

driver="$bridge_build/$bridge_name.driver"
ditto "$bridge_build/products/BlackHole.driver" "$driver"
rm -f "$driver/Contents/Resources/BlackHole.icns"
/usr/libexec/PlistBuddy -c "Set :CFBundleName $bridge_name" "$driver/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $bridge_name" "$driver/Contents/Info.plist" 2>/dev/null || true

codesign --force --deep --options runtime --timestamp \
  --sign "$application_identity" "$driver"
codesign --verify --deep --strict --verbose=2 "$driver"

installer_app="$bridge_build/$installer_name.app"
mkdir -p "$installer_app/Contents/MacOS" "$installer_app/Contents/Resources"
sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
for architecture in arm64 x86_64; do
  swiftc -O -framework AppKit \
    -sdk "$sdk_path" \
    -target "$architecture-apple-macosx14.0" \
    "$bridge_root/InstallerApp/main.swift" \
    -o "$bridge_build/PersonalInterpreterMicInstaller-$architecture"
done
lipo -create \
  "$bridge_build/PersonalInterpreterMicInstaller-arm64" \
  "$bridge_build/PersonalInterpreterMicInstaller-x86_64" \
  -output "$installer_app/Contents/MacOS/PersonalInterpreterMicInstaller"

cp "$bridge_root/InstallerApp/Info.plist" "$installer_app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $bridge_version" "$installer_app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bridge_version" "$installer_app/Contents/Info.plist"
ditto "$driver" "$installer_app/Contents/Resources/$bridge_name.driver"

codesign --force --deep --options runtime --timestamp \
  --sign "$application_identity" "$installer_app"
codesign --verify --deep --strict --verbose=4 "$installer_app"

archive="$bridge_build/PersonalInterpreterAudioBridge-$bridge_version.zip"
ditto -c -k --sequesterRsrc --keepParent "$installer_app" "$archive"

if [[ -n "${PI_NOTARY_PROFILE:-}" ]]; then
  xcrun notarytool submit "$archive" --keychain-profile "$PI_NOTARY_PROFILE" --wait
  xcrun stapler staple "$installer_app"
  xcrun stapler validate "$installer_app"
  rm -f "$archive"
  ditto -c -k --sequesterRsrc --keepParent "$installer_app" "$archive"
elif [[ -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  xcrun notarytool submit "$archive" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait
  xcrun stapler staple "$installer_app"
  xcrun stapler validate "$installer_app"
  rm -f "$archive"
  ditto -c -k --sequesterRsrc --keepParent "$installer_app" "$archive"
else
  print -u2 "Built and signed, but not notarized. Do not publish this archive yet."
  print -u2 "Set PI_NOTARY_PROFILE or Apple notarization environment variables and rerun."
fi

print "Built: $archive"
