#!/bin/bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
windows_dir="$project_root/Windows"
project="$windows_dir/QuarkSwitch.Windows/QuarkSwitch.Windows.csproj"
output_dir="$project_root/dist-windows"
icon_source="$project_root/QuarkSwitch/Assets.xcassets/AppIcon.appiconset/icon_256x256.png"
icon_output="$windows_dir/QuarkSwitch.Windows/Assets/QuarkSwitch.ico"

command -v dotnet >/dev/null || { printf 'dotnet SDK is required.\n' >&2; exit 1; }
command -v makensis >/dev/null || { printf 'NSIS (makensis) is required.\n' >&2; exit 1; }
mkdir -p "$(dirname "$icon_output")" "$output_dir"
sips -s format ico "$icon_source" --out "$icon_output" >/dev/null

version="$(sed -n 's:.*<Version>\([^<]*\)</Version>.*:\1:p' "$project" | head -1)"
[[ -n "$version" ]] || { printf 'Unable to read project version.\n' >&2; exit 1; }

printf 'Publishing self-contained Windows x64 executable…\n'
dotnet run --project "$windows_dir/Tests/QuarkSwitch.Windows.Tests.csproj" -c Release
dotnet publish "$project" -c Release -r win-x64 --self-contained true \
    -p:PublishSingleFile=true -p:DebugType=None -p:DebugSymbols=false

publish_dir="$windows_dir/QuarkSwitch.Windows/bin/Release/net10.0-windows/win-x64/publish"
test -f "$publish_dir/QuarkSwitch.exe"
cp "$publish_dir/QuarkSwitch.exe" "$output_dir/QuarkSwitch-$version-win-x64.exe"

printf 'Building per-user NSIS installer…\n'
makensis \
    -DVERSION="$version" \
    -DSOURCE_DIR="$publish_dir" \
    -DOUTPUT_FILE="$output_dir/QuarkSwitch-Setup-$version-x64.exe" \
    "$windows_dir/Installer/QuarkSwitch.nsi"

shasum -a 256 "$output_dir/QuarkSwitch-$version-win-x64.exe" \
    "$output_dir/QuarkSwitch-Setup-$version-x64.exe" > "$output_dir/SHA256SUMS.txt"
printf '\nCreated:\n  %s\n  %s\n' \
    "$output_dir/QuarkSwitch-$version-win-x64.exe" \
    "$output_dir/QuarkSwitch-Setup-$version-x64.exe"
printf 'Unsigned Windows build: SmartScreen may warn until the app is code-signed.\n'
