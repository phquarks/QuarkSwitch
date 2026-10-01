import SwiftUI

struct OnboardingView: View {
    @ObservedObject var state: AppState
    @ObservedObject private var permissions: PermissionManager
    @State private var step = 0
    @AccessibilityFocusState private var headingFocused: Bool
    let dismiss: () -> Void

    init(state: AppState, dismiss: @escaping () -> Void) {
        self.state = state
        permissions = state.permissions
        self.dismiss = dismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("QuarkSwitch", systemImage: "character.cursor.ibeam")
                    .font(.headline)
                Spacer()
                Text("\(step + 1) of 3").foregroundStyle(.secondary)
            }
            .padding(24)

            Divider()

            Group {
                switch step {
                case 0: welcome
                case 1: permissionsStep
                default: ready
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(42)

            Divider()

            HStack {
                if step > 0 { Button("Back") { step -= 1 } }
                Spacer()
                Button(step == 2 ? "Start QuarkSwitch" : "Continue") {
                    if step == 2 {
                        state.settings.hasCompletedOnboarding = true
                        state.keyboardMonitor.restartIfPossible()
                        dismiss()
                    } else { step += 1 }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .background(.background)
        .onAppear { headingFocused = true }
        .onChange(of: step) { _, _ in
            DispatchQueue.main.async { headingFocused = true }
        }
    }

    private var welcome: some View {
        VStack(spacing: 22) {
            Image(systemName: "character.cursor.ibeam")
                .font(.system(size: 58, weight: .medium))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            CorrectionExampleView()
            Text("Type in the right language,\neven when the layout is wrong")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($headingFocused)
            Text("QuarkSwitch recognizes high-confidence layout mistakes like “ghbdtn” and replaces them locally with “привет”. Your typing is never uploaded or saved.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 470)
        }
    }

    private var permissionsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Two permissions make correction possible")
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($headingFocused)
            PermissionRow(title: "Accessibility",
                          detail: "Allows QuarkSwitch to replace a confirmed wrong-layout word.",
                          isGranted: permissions.hasAccessibility,
                          action: permissions.requestAccessibility)
            PermissionRow(title: "Input Monitoring",
                          detail: "Keeps only the current or most recent word in memory and clears it within 12 seconds.",
                          isGranted: permissions.hasInputMonitoring,
                          action: permissions.requestInputMonitoring)
            Text("QuarkSwitch never analyzes secure text fields. You can continue without permission and grant access later in Settings.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var ready: some View {
        VStack(spacing: 22) {
            Image(systemName: permissions.allGranted ? "checkmark.seal.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 54))
                .foregroundStyle(permissions.allGranted ? Color.green : Color.orange)
            Text(permissions.allGranted ? "Ready in the menu bar" : "Ready with limited access")
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($headingFocused)
            Text(permissions.allGranted
                 ? "Automatic correction is on. Use Option–Space to convert selected text at any time."
                 : "The app will stay idle until both permissions are granted. Open Settings → Privacy when you’re ready.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 430)
        }
    }
}

struct PermissionRow: View {
    let title: String
    let detail: String
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isGranted ? Color.green : Color.secondary)
                .accessibilityLabel(isGranted ? "Granted" : "Not granted")
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }
            Spacer()
            if !isGranted { Button("Open System Settings", action: action) }
        }
        .accessibilityElement(children: .combine)
    }
}

struct CorrectionExampleView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("ghbdtn")
                .strikethrough(true, color: .red)
                .foregroundStyle(.secondary)
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("привет")
                .fontWeight(.semibold)
                .foregroundStyle(.tint)
        }
        .font(.system(.title3, design: .monospaced))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Example correction: ghbdtn becomes привет")
    }
}
