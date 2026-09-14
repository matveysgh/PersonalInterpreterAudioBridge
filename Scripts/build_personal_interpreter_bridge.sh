#!/bin/zsh
set -euo pipefail

bridge_root="${0:A:h:h}"
bridge_build="$bridge_root/build-personal-interpreter"
bridge_name="Personal Interpreter Mic"
bridge_bundle_id="com.interpreter.PersonalInterpreter.AudioBridge"
bridge_version="$(<"$bridge_root/VERSION")"
application_identity="${PI_APPLICATION_IDENTITY:-Developer ID Application: Nataliya Tkachova (4YDWLX6Y9Y)}"
installer_identity="${PI_INSTALLER_IDENTITY:-}"

if [[ -z "$installer_identity" ]]; then
  print -u2 "PI_INSTALLER_IDENTITY is required (Developer ID Installer certificate)."
  exit 64
fi

rm -rf "$bridge_build"
mkdir -p "$bridge_build/package-root"

xcodebuild \
  -project "$bridge_root/BlackHole.xcodeproj" \
  -configuration Release \
  -target BlackHole \
  CONFIGURATION_BUILD_DIR="$bridge_build/products" \
  MACOSX_DEPLOYMENT_TARGET=14.0 \
  PRODUCT_BUNDLE_IDENTIFIER="$bridge_bundle_id"

driver_source="$bridge_build/products/BlackHole.driver"
driver_destination="$bridge_build/package-root/$bridge_name.driver"
ditto "$driver_source" "$driver_destination"
rm -f "$driver_destination/Contents/Resources/BlackHole.icns"

/usr/libexec/PlistBuddy -c "Set :CFBundleName $bridge_name" "$driver_destination/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $bridge_name" "$driver_destination/Contents/Info.plist" 2>/dev/null || true

codesign --force --deep --options runtime --timestamp \
  --sign "$application_identity" "$driver_destination"
codesign --verify --deep --strict --verbose=2 "$driver_destination"

pkgbuild \
  --identifier "$bridge_bundle_id" \
  --version "$bridge_version" \
  --root "$bridge_build/package-root" \
  --install-location /Library/Audio/Plug-Ins/HAL \
  --sign "$installer_identity" \
  "$bridge_build/PersonalInterpreterAudioBridge-$bridge_version.pkg"

print "Built: $bridge_build/PersonalInterpreterAudioBridge-$bridge_version.pkg"
print "Next: notarize, staple, verify, then publish the package with this GPLv3 source tag."
