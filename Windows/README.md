# QuarkSwitch for Windows

The Windows port is a native WinForms tray application targeting Windows 10/11 x64. It is self-contained: the destination PC does not need .NET installed.

Features:

- global English QWERTY ↔ Russian ЙЦУКЕН word conversion;
- conservative automatic correction at Space, Enter, and Tab;
- `Ctrl+Alt+Space` to convert selected text;
- `Ctrl+Alt+Shift+Space` to convert the recent word;
- `Ctrl+Z` to undo and learn from a recent automatic correction;
- automatic switch to the intended Windows input layout;
- pause, sensitivity, autostart, settings, and About from the system tray;
- local-only settings under `%LOCALAPPDATA%\Quarks\QuarkSwitch`;
- terminal and conventional password edit controls are skipped.

## Build on macOS

Install the .NET SDK and NSIS, then run:

```sh
Windows/build-windows.sh
```

Outputs are written to `dist-windows/`:

- `QuarkSwitch-VERSION-win-x64.exe` — portable single-file app;
- `QuarkSwitch-Setup-VERSION-x64.exe` — per-user installer;
- `SHA256SUMS.txt`.

The build first runs platform-neutral conversion and detection regression checks, including `ghbdtn → привет`, `руддщ → hello`, and `[jhjij → хорошо`.

The build is not Authenticode-signed. Windows SmartScreen warnings are possible until a trusted code-signing certificate is used. Global hooks cannot inspect every browser-rendered password field, so automatic correction should be paused before entering secrets in unsupported applications.
