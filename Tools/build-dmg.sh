#!/bin/bash
set -euo pipefail

if [[ "${1:-}" != "--adhoc" || $# -ne 1 ]]; then
    printf 'Usage: Tools/build-dmg.sh --adhoc\n' >&2
    exit 2
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tools_dir="$project_root/Tools"
output_dir="$project_root/dist"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/QuarkSwitch-dmg.XXXXXX")"
cleanup() {
    case "$work_dir" in
        */QuarkSwitch-dmg.*) /bin/rm -rf "$work_dir" ;;
    esac
}
trap cleanup EXIT
mkdir -p "$output_dir" "$work_dir/staging" "$work_dir/AppIcon.iconset"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONPATH="$tools_dir/dmg-python${PYTHONPATH:+:$PYTHONPATH}"
python_bin="${PYTHON_BIN:-python3}"
"$python_bin" -c 'import dmgbuild, ds_store, mac_alias' || {
    printf 'Bundled dmgbuild modules are missing from Tools/dmg-python.\n' >&2
    exit 1
}

printf 'Building Release for Apple Silicon and Intel…\n'
xcodebuild -quiet -project "$project_root/QuarkSwitch.xcodeproj" \
    -scheme QuarkSwitch -configuration Release -destination 'generic/platform=macOS' \
    -derivedDataPath "$work_dir/DerivedData" \
    ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO build

source_app="$work_dir/DerivedData/Build/Products/Release/QuarkSwitch.app"
app_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$source_app/Contents/Info.plist")"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$source_app/Contents/Info.plist")"
build_number="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$source_app/Contents/Info.plist")"
for value in "$app_name" "$version" "$build_number"; do
    if [[ "$value" == *'/'* || "$value" == *$'\n'* ]]; then
        printf 'Unsafe filename component in built Info.plist.\n' >&2
        exit 1
    fi
done
staged_app="$work_dir/staging/$app_name.app"
ditto "$source_app" "$staged_app"
cp "$tools_dir/Installation Guide.txt" "$work_dir/staging/Installation Guide.txt"

printf 'Preparing Finder icons…\n'
xcrun swiftc -module-cache-path "$work_dir/SwiftModules" \
    "$project_root/QuarkSwitch/App/QuarkSwitchIcon.swift" "$tools_dir/render-dmg-icons.swift" \
    -o "$work_dir/render-dmg-icons"
"$work_dir/render-dmg-icons" "$work_dir/staging"
for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$work_dir/staging/app-icon.png" \
        --out "$work_dir/AppIcon.iconset/icon_${size}x${size}.png" >/dev/null
    double_size=$((size * 2))
    sips -z "$double_size" "$double_size" "$work_dir/staging/app-icon.png" \
        --out "$work_dir/AppIcon.iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$work_dir/AppIcon.iconset" -o "$work_dir/staging/$app_name.icns"
mkdir -p "$staged_app/Contents/Resources"
cp "$work_dir/staging/$app_name.icns" "$staged_app/Contents/Resources/AppIcon.icns"
if /usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$staged_app/Contents/Info.plist" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c 'Set :CFBundleIconFile AppIcon' "$staged_app/Contents/Info.plist"
else
    /usr/libexec/PlistBuddy -c 'Add :CFBundleIconFile string AppIcon' "$staged_app/Contents/Info.plist"
fi

printf 'Ad-hoc signing and verifying…\n'
codesign --force --deep --options runtime --sign - "$staged_app"
codesign --verify --deep --strict --verbose=2 "$staged_app"
executable="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$staged_app/Contents/Info.plist")"
xcrun lipo "$staged_app/Contents/MacOS/$executable" -verify_arch arm64
xcrun lipo "$staged_app/Contents/MacOS/$executable" -verify_arch x86_64

# A fresh TIFF source ensures dmgbuild writes .background.tiff, avoiding the
# previously cached .background.png name in Finder. Never redraw the PNG.
sips -s format tiff "$tools_dir/dmg-background.png" \
    --out "$work_dir/dmg-background.tiff" >/dev/null
dmg_path="$output_dir/$app_name-$version-$build_number-ADHOC.dmg"
printf 'Writing DMG layout via .DS_Store…\n'
"$python_bin" -m dmgbuild --no-hidpi -s "$tools_dir/dmg-settings.py" \
    -D "staging=$work_dir/staging" -D "app_name=$app_name" \
    -D "background=$work_dir/dmg-background.tiff" \
    "$app_name" "$dmg_path"
hdiutil verify "$dmg_path"
shasum -a 256 "$dmg_path" | tee "$dmg_path.sha256"
printf '\nCreated: %s\n' "$dmg_path"
printf 'Ad-hoc only: Gatekeeper warnings remain possible; no notarization was performed.\n'
