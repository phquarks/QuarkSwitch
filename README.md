# QuarkSwitch

QuarkSwitch is a privacy-first native macOS menu bar app that detects words typed in the wrong English or Russian keyboard layout and corrects them when confidence is high.

Detection uses the local macOS spelling dictionaries in addition to frequency hints and character n-grams. Layout keys such as `[`, `;`, `'`, `,`, and `.` are retained inside the word because they may represent Russian letters. Ambiguous punctuation is resolved when the word ends at a space, Enter, or Tab; final sentence punctuation is compared separately and preserved.

## Requirements

- Xcode 27 or later
- macOS 15 or later (macOS 27 is the primary target)
- Accessibility and Input Monitoring permissions for global correction

## Build

Open `QuarkSwitch.xcodeproj` in Xcode, select the **QuarkSwitch** scheme, and run. No package installation or generated source step is required.

From Terminal:

```sh
xcodebuild -project QuarkSwitch.xcodeproj -scheme QuarkSwitch -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

## Privacy and sandboxing

The app keeps only the current or most recent word in memory (cleared within 12 seconds), skips secure text fields, and stores only user-authored exceptions and aggregate counters. It has no networking or analytics dependency.

App Sandbox is intentionally disabled because a sandboxed app cannot provide the required global event-tap and cross-application Accessibility behavior. Hardened Runtime is enabled. A production distribution should be Developer ID signed and notarized.

## Default shortcuts

- **Option–Space:** convert selected text
- **Option–Command–Space:** convert the current or most recent word
- **Command–Z:** undo the most recent automatic correction while it is still current

Terminal and iTerm are excluded by default to minimize command-line false positives. IDEs remain enabled and can be excluded in Settings → Applications.

## Regression checks

The executable checks token boundaries, `[jhjij → хорошо`, punctuation within Russian words, broader dictionary coverage, sentence punctuation, and protected English/technical tokens:

```sh
xcrun swiftc QuarkSwitch/Models/Models.swift QuarkSwitch/LayoutConverter/LayoutConverter.swift QuarkSwitch/LanguageDetector/LanguageDetector.swift QuarkSwitch/LanguageDetector/WordAnalyzer.swift QuarkSwitch/KeyboardMonitor/WordBuffer.swift Tests/LayoutRegressionTests.swift -o /tmp/QuarkSwitchRegressionTests
/tmp/QuarkSwitchRegressionTests
```

The test must have access to the local macOS spelling service.
