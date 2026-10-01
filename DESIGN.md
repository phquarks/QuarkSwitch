---
name: QuarkSwitch
description: A restrained native macOS utility for quiet, reversible keyboard-layout correction.
typography:
  display:
    fontFamily: "SF Pro Rounded, system rounded"
    fontSize: "30px"
    fontWeight: 600
  headline:
    fontFamily: "SF Pro, system"
    fontSize: "28px"
    fontWeight: 600
  statistic:
    fontFamily: "SF Pro Rounded, system rounded"
    fontSize: "34px"
    fontWeight: 600
  body:
    fontFamily: "SF Pro, system"
  code:
    fontFamily: "SF Mono, system monospaced"
rounded:
  compact: "6px"
  badge: "9px"
spacing:
  micro: "4px"
  compact: "10px"
  inline: "12px"
  row: "16px"
  section: "22px"
  chrome: "24px"
  detail: "32px"
  stage: "42px"
components:
  shortcut-keycap:
    typography: "{typography.code}"
    rounded: "{rounded.compact}"
    padding: "4px 9px"
  language-badge:
    rounded: "{rounded.badge}"
    padding: "10px 13px"
---

# Design System: QuarkSwitch

## Overview

**Creative North Star: "The Restrained Redline Editor"**

QuarkSwitch is an invisible bilingual proofreader, not a dashboard. Its visual system is a quiet native macOS workspace: graphite system surfaces, compact controls, hairline divisions, SF Symbols, and direct status language. The operating interface recedes so the correction mechanism and the user’s control remain legible.

The one expressive device is the redline correction example: a wrong-layout token is struck through in restrained red, then points to the corrected token in the current system accent. Onboarding makes this mechanism visible before asking for permissions; Settings returns to conventional macOS structure and density. All surfaces follow the user’s appearance, accent color, text settings, and accessibility preferences instead of imposing a fixed brand palette.

**Key Characteristics:**

- Native macOS controls and semantic system materials.
- Graphite-neutral surfaces with color reserved for accent, state, and the redline example.
- Compact information density, hairline dividers, and clear left-aligned settings groups.
- One primary action per onboarding step and immediate paths to pause, undo, or configure.
- SF Symbols with text labels; status and permission meaning never depends on color alone.

## Colors

The palette is deliberately dynamic: SwiftUI semantic styles and AppKit system colors adapt to appearance, contrast, and the user’s chosen macOS accent. There are no hard-coded brand hex values.

### Primary

- **System Accent:** `.tint` marks the onboarding cursor, corrected output, language codes, privacy icons, selection, and the bordered-prominent step action. It inherits the user’s macOS accent and must not be replaced with a fixed blue.

### Tertiary

- **Permission Granted:** system green identifies granted permissions and the full-access completion state, always paired with a checkmark and explicit text.
- **Attention / Limited Access:** system orange identifies warnings and reduced capability, always paired with a warning symbol and explanatory copy.
- **Editorial Redline:** system red appears only as the strike-through on the incorrect token in the correction example and as the native destructive role for irreversible local actions.

### Neutral

- **Window Background:** SwiftUI `.background` is the onboarding canvas.
- **Graphite Detail Surface:** AppKit `controlBackgroundColor` at 35% opacity distinguishes the Settings detail pane without turning it into a card.
- **Secondary Content:** `.secondary` carries descriptions, counters, inactive status, slider endpoints, and supporting icons.
- **Quiet Fill:** `.quaternary` fills shortcut keycaps and language badges.
- **Hairline Division:** native `Divider` separates window chrome and settings groups.

### Named Rules

**The System Owns the Palette Rule.** Use semantic system styles so light mode, dark mode, increased contrast, and the user’s accent remain authoritative.

**The Redline Is Evidence Rule.** Red belongs to the incorrect token or a native destructive action; it is not decoration, branding, or a general emphasis color.

**The Icon-Plus-Language Rule.** Green, orange, and accent color always accompany a symbol and plain-language state.

## Typography

**Display Font:** SF Pro Rounded through SwiftUI’s system rounded design.
**Body Font:** SF Pro through native semantic text styles.
**Label/Mono Font:** SF Mono through SwiftUI’s system monospaced design.

**Character:** System typography keeps the utility familiar and readable. Rounded semibold type is reserved for the warm onboarding promise and aggregate statistics; monospaced type makes inputs, outputs, bundle identifiers, and shortcuts feel literal without making the app look like a developer tool.

### Hierarchy

- **Display** (semibold, 30px): the centered first-run promise only; it may wrap across two deliberate lines.
- **Headline** (semibold, 28px): the title of each Settings detail section, paired with a hierarchical SF Symbol.
- **Step Title** (native bold title): permission and readiness headings in onboarding.
- **Section Title** (native headline): settings block titles, permission names, the app name in onboarding chrome, and language codes.
- **Body** (native body): controls, values, lists, and operational language.
- **Supporting Copy** (native callout or caption): details, privacy explanations, threshold labels, errors, and secondary status.
- **Statistic** (rounded semibold, 34px): aggregate correction counts only.
- **Code / Keycap** (native monospaced): the correction example, keyboard shortcuts, layout mappings, and bundle identifiers.

### Named Rules

**The Semantic Type Rule.** Prefer native text styles so accessibility sizing and platform metrics remain intact; use fixed sizes only for the three implemented display moments.

**The Mono Means Literal Rule.** Monospaced type is for typed characters, shortcuts, mappings, and identifiers—not for headings or explanatory prose.

## Layout

The app has three native spatial models. The menu-bar interface is a standard menu divided into operational, manual-control, navigation, status, and application groups. Onboarding is a fixed 620 × 520 window with transparent title-bar treatment, 24px header and footer insets, hairline dividers, and a flexible central stage padded by 42px. Its first and final steps are centered; the permissions step is left aligned.

Settings uses `NavigationSplitView` in a resizable window initially sized to 820 × 590 and never smaller than 760 × 520. The sidebar is 180–220px wide with a 190px ideal. The scrollable detail column is capped at 610px, aligned to the leading edge, and inset by 32px. Detail groups stack on a 22px rhythm and use native dividers rather than card containers.

Within groups, 10–16px spacing separates related labels, icons, and controls. Repeated row content keeps labels leading and actions or compact values trailing with a flexible spacer. This alignment is the main settings rhythm; do not center ordinary settings content.

**The Window-Chrome / Work-Area Rule.** Onboarding may center a single message in its stage, but Settings remains a leading-aligned work area inside the native split view.

**The Divider-Not-Card Rule.** Separate settings concepts with whitespace and native hairlines, not a stack of elevated rounded cards.

## Elevation & Depth

QuarkSwitch is flat by default. It uses window chrome, split-view separation, a faint system control-background wash, dividers, and native control fills to establish depth. No custom shadows, glows, gradients, translucency effects, or floating panels are implemented. Menus, alerts, text fields, and prominent buttons retain macOS-provided elevation and focus treatment.

**The Native Depth Rule.** Let macOS supply focus rings, menu depth, alerts, and control elevation; do not add custom shadows to settings blocks or onboarding content.

## Shapes

The form language is native and compact. Buttons, toggles, sliders, text fields, alerts, list selections, and menu items keep their system shapes. Custom rounded rectangles appear only behind compact literal values: shortcut keycaps use a 6px corner radius, and language badges use 9px. There are no ornamental pills, circular text buttons, or rounded card shells.

**The Contained Literal Rule.** A custom rounded fill may contain a short code, shortcut, or language pair; explanatory content remains unboxed.

## Components

### App Icon

The existing Quarks Q identity expands into a graphite rounded tile with a silver Q and two opposing lavender arrows for keyboard-layout switching. The tile occupies 88% of the square canvas, leaving a transparent 6% perimeter on each edge; its subtle gradient and fine highlight belong to the icon artwork, not the operating interface.

`QuarkSwitch/App/QuarkSwitchIcon.swift` is the standalone SwiftUI drawing source used in About and by the DMG rendering helper. `Assets.xcassets/AppIcon.appiconset` provides native macOS 1× and 2× slots from 16 × 16 through 512 × 512 points, reaching 1024 × 1024 pixels. Packaging renders the same source into the app and DMG icons, preserving one identity across About, Finder, and distribution.

### About Window — Screenshot-Matched Exception

The user supplied the Tucker About window as the exact visual reference on 2026-10-01. QuarkSwitch's About window therefore uses a fixed dark appearance, a near-black identity band, a graphite information area, and a lavender outlined developer-website link. This is an intentional exception to the semantic palette elsewhere in the app. The 500 × 510 content area uses a vector Q mark, rounded bold product title, a two-line typing tagline, Developer/Requires rows, quarks.kz, a thin separator, and copyright. Native AppKit window chrome remains intact. The window is reused when reopened and its external link is keyboard-accessible.

The menu now contains Auto Switch, Pause/Resume, manual conversion actions, conditional Undo, Settings, About, and Quit. Current Layout, Statistics/Permissions shortcuts, correction totals, and diagnostic status rows were removed at the user's request; statistics and permission controls remain in Settings.

### Onboarding Window

- **Structure:** branded header and step counter, hairline divider, flexible content stage, second divider, and navigation footer.
- **Primary Action:** a native bordered-prominent `Continue` or `Start QuarkSwitch` button at the trailing edge; it is the sole emphasized action on each step.
- **Progression:** three steps—mechanism and privacy, two explicit permissions, then full-access or limited-access readiness.
- **Focus:** VoiceOver focus moves to the new heading when a step appears.
- **State:** the final symbol and copy change between granted and limited access; either state can complete onboarding.

### Correction Example

- **Character:** a compact editorial redline that demonstrates the product rather than decorating it.
- **Style:** monospaced title text; the source token is secondary with a red strike-through, the arrow is secondary, and the corrected token is semibold in the system accent.
- **Accessibility:** the visual children collapse into one label describing the transformation.

### Permission Row

- **Structure:** 16px row spacing, status symbol, leading title/detail stack, flexible space, and a native `Open System Settings` action only when access is missing.
- **State:** granted uses a green filled checkmark; not granted uses a secondary empty circle. Both expose explicit “Granted” or “Not granted” accessibility labels.
- **Copy:** detail text states exactly what the permission enables; the surrounding view explains reduced behavior.

### Navigation

- **Settings:** `NavigationSplitView` with a native selectable `List`; every section is a text label paired with an SF Symbol.
- **Menu Bar:** the status-item SF Symbol follows the operational state and exposes `QuarkSwitch: [status]` to accessibility. Its menu uses native ordering, dividers, keyboard shortcuts, and destructive or quit conventions.
- **Detail Header:** a 28px semibold label with a hierarchical rendering-mode symbol.

### Settings Blocks and Rows

- **Structure:** leading-aligned title, optional secondary callout, then native controls or value rows. Related blocks are separated by dividers.
- **Controls:** use native toggles, sliders, buttons, alerts, rounded-border text fields, and `ContentUnavailableView`.
- **Compact Values:** shortcuts use monospaced text in a quaternary 6px-radius keycap; language pairs use quaternary 9px-radius badges with accent codes.
- **Destructive State:** `Reset Statistics…` uses the native destructive role and requires a confirmation alert that states what is and is not removed.

### Status and Empty States

- **Operational State:** status is always named in text; menu-bar imagery is supplementary.
- **Permission State:** full and limited access have distinct symbols, headings, and explanatory copy.
- **Empty Collection:** Exceptions uses native `ContentUnavailableView` with an SF Symbol and a next-step description.
- **Validation:** add/exclude actions disable until their text input meets the implemented minimum validity check.

## Do's and Don'ts

### Do:

- **Do** use SwiftUI semantic colors, materials, text styles, controls, focus rings, and SF Symbols.
- **Do** keep onboarding to one emphasized action per step and allow the limited-access path to complete honestly.
- **Do** use leading labels and trailing controls or values for scan-friendly settings rows.
- **Do** pair every visual status with a symbol, heading or label, and plain-language explanation.
- **Do** preserve keyboard navigation, VoiceOver labels, heading traits, reduced-motion behavior, contrast adaptation, and legibility at increased system text sizes.
- **Do** keep typed-content examples generic and transient; statistics surfaces show aggregate counts only.

### Don't:

- **Don't** hard-code a brand blue, graphite hex palette, light-only colors, or web-style design tokens in place of macOS semantic styles.
- **Don't** turn Settings into a dashboard of cards, charts, gradients, or custom navigation.
- **Don't** use the redline treatment outside correction examples or native destructive actions.
- **Don't** add decorative imagery, custom icon artwork, or marketing claims that are not part of the shipped application.
- **Don't** communicate permission, error, pause, or readiness state through color alone.
- **Don't** display typed words as history or imply that QuarkSwitch retains them.
