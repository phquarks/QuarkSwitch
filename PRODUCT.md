# QuarkSwitch

<!-- impeccable:product-schema 1 -->

## Platform

macOS 15 and later, with macOS 27 as the primary compatibility target.

## Stack

Delegated by the supplied brief: Swift, SwiftUI, AppKit where needed, Accessibility, Core Graphics event taps, NaturalLanguage, ServiceManagement, and public Apple APIs only. The app is a native menu-bar application built with Xcode 27.

## Users

Inferred from the supplied brief: people who type in both Russian and English on a Mac and regularly discover that the wrong keyboard layout was active only after finishing a word.

## Product Purpose

QuarkSwitch detects a likely wrong Russian/English keyboard layout at a word boundary, converts the just-typed word only when confidence is high, and lets the user undo or manually convert text. Success means preventing layout mistakes without disturbing legitimate words, technical text, or private input.

## Positioning

The product works from a minimal, short-lived current-word buffer and local scoring. It does not upload, retain, or reconstruct the user's typing history.

## Operating Context

QuarkSwitch runs mainly from the macOS menu bar and works across applications where macOS Accessibility and Input Monitoring permit it. First-run permission guidance, explicit pause controls, application exclusions, manual conversion shortcuts, and aggregated local statistics are core workflows.

## Capabilities and Constraints

- English QWERTY and Russian ЙЦУКЕН conversion in both directions, including case and punctuation.
- Conservative dictionary, n-gram, heuristic, and NaturalLanguage scoring.
- No analysis in secure fields; no automatic changes to URLs, email, domains, IPs, paths, code-like tokens, commands, numbers, abbreviations, or user exceptions.
- Accessibility and Input Monitoring may be declined; the app must remain stable and explain reduced functionality.
- Local learning records exceptions and aggregate correction/undo counts, never full typing history.
- No server, third-party analytics, or private/deprecated API when a current public API exists.
- The App Sandbox is intentionally not enabled because global event taps and cross-application Accessibility replacement are the product's core behavior; hardened runtime remains enabled.

## Brand Commitments

The name is QuarkSwitch. The voice is concise, calm, transparent, and privacy-forward. The supplied brief requires a compact menu-bar presence and a Settings window in the style of modern macOS applications.

## Evidence on Hand

The supplied product brief and concrete examples `ghbdtn → привет` and `руддщ → hello`. No external brand assets, customer claims, benchmarks, or analytics data were supplied and none may be fabricated.

## Product Principles

1. Prefer no correction to a false correction.
2. Keep typed content ephemeral and local.
3. Make every automatic action immediately reversible.
4. Explain permissions and degraded states in plain language.
5. Follow native macOS interaction, accessibility, and energy conventions.

## Accessibility & Inclusion

Use native controls, keyboard navigation, VoiceOver labels, Reduce Motion, sufficient contrast, and text that remains legible at increased system text sizes. Permission and error states must never rely on color alone.

## Open Decisions

The supplied brief does not define a distribution channel, signing team, App Store strategy, custom icon artwork, localization beyond English/Russian input handling, or a large licensed word-frequency corpus. These remain deliberately undecided.
