# Ad-hoc DMG distribution

Run from the project checkout:

```sh
Tools/build-dmg.sh --adhoc
```

Requires macOS, Xcode 27 with command-line tools, and Python 3.10 or later. The script uses the source project and QuarkSwitch scheme. It builds a universal `arm64`/`x86_64` Release for macOS 15+, reads version/build/name from the built Info.plist, renders the shared QuarkSwitch Q-and-switch-arrows artwork as the package icon, applies an ad-hoc hardened-runtime signature, and verifies it. Application behavior is unchanged. The same artwork is included in the Xcode AppIcon asset catalog and About window.

The result is `dist/QuarkSwitch-VERSION-BUILD-ADHOC.dmg` with an adjacent `.sha256` checksum. Temporary staging, icon generation, TIFF conversion, and DerivedData live under a unique temporary folder which is removed on exit.

`dmg-settings.py` defines a 720×460 Finder icon view with three positions aligned to the supplied background. `dmg-background.png` is the user's original 1569×1002 image proportionally resized to 720×460 with `sips -Z 720`. Its logo, watermark, frames, and arrow are preserved. Each build creates a temporary TIFF so dmgbuild stores the background as `.background.tiff`. Finder layout is written via `.DS_Store`; no Finder AppleScript is used.

Finder uses one global icon size, set to 108 points. The upper icons are centered at (196, 148) and (524, 148), and the guide at (360, 313), keeping labels inside the window. The Installation Guide receives a custom document icon drawn smaller on a transparent canvas, while all filenames use compact 11-point labels. Its resource fork is preserved by dmgbuild's `ditto` copy.

## Bundled Python dependencies

The following pure-Python packages are checked in under `Tools/dmg-python` with their distribution metadata and licenses:

- dmgbuild 1.6.7
- ds_store 1.3.3
- mac_alias 2.2.3

The build does not run pip or access the network. `PYTHON_BIN` may select another Python 3 interpreter. Bytecode generation is disabled during packaging; `__pycache__`, build folders, `.DS_Store`, and DMGs are excluded by `.gitignore`.

## Gatekeeper

Ad-hoc signing verifies local code integrity. It is not Developer ID signing or Apple notarization and does not remove Gatekeeper warnings for downloaded copies. The included Installation Guide describes drag-to-Applications, right-click Open, Privacy & Security > Open Anyway, and an optional quarantine-removal command for users who trust the source. No paid Apple Developer membership, Developer ID certificate, App Store publication, or notarization is used.
