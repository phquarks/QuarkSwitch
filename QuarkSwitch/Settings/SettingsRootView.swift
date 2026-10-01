import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var state: AppState
    @ObservedObject private var navigation = SettingsNavigation.shared

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $navigation.requestedSection) { section in
                Label(section.rawValue, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 190, max: 220)
        } detail: {
            SettingsDetail(state: state, section: navigation.requestedSection)
                .id(navigation.requestedSection)
        }
        .frame(minWidth: 760, minHeight: 520)
    }
}

private struct SettingsDetail: View {
    @ObservedObject var state: AppState
    let section: SettingsSection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Label(section.rawValue, systemImage: section.systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityAddTraits(.isHeader)

                switch section {
                case .general: GeneralSettingsView(state: state)
                case .autoSwitch: AutoSwitchSettingsView(state: state)
                case .hotkeys: HotkeysSettingsView(state: state)
                case .languages: LanguagesSettingsView()
                case .exceptions: ExceptionsSettingsView(manager: state.exceptions)
                case .applications: ApplicationsSettingsView(filter: state.applicationFilter)
                case .privacy: PrivacySettingsView(state: state)
                case .statistics: StatisticsSettingsView(manager: state.statistics)
                }
            }
            .frame(maxWidth: 610, alignment: .leading)
            .padding(32)
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
    }
}

private struct SettingBlock<Content: View>: View {
    let title: String
    let detail: String?
    @ViewBuilder let content: Content

    init(_ title: String, detail: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            if let detail { Text(detail).font(.callout).foregroundStyle(.secondary) }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var state: AppState
    @ObservedObject private var settings: SettingsManager

    init(state: AppState) {
        self.state = state
        settings = state.settings
    }

    var body: some View {
        SettingBlock("Startup") {
            Toggle("Launch QuarkSwitch at login", isOn: Binding(
                get: { settings.launchAtLogin },
                set: settings.setLaunchAtLogin
            ))
            if let error = settings.launchAtLoginError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.callout).foregroundStyle(.orange)
            }
        }
        Divider()
        SettingBlock("Behavior") {
            Toggle("Enable Auto Switch", isOn: $settings.isAutoSwitchEnabled)
            Toggle("Play a sound after correction", isOn: $settings.playSound)
            Toggle("Show a notification after correction", isOn: Binding(
                get: { settings.showNotification }, set: settings.setNotificationsEnabled
            ))
            Toggle("Show menu bar icon", isOn: $settings.showMenuBarIcon)
        }
        Divider()
        SettingBlock("Pause") {
            HStack {
                Text(settings.isPaused ? "Paused until \(settings.pauseUntil?.formatted(date: .omitted, time: .shortened) ?? "later")" : "Automatic correction is active")
                    .foregroundStyle(.secondary)
                Spacer()
                if settings.isPaused { Button("Resume") { settings.resume() } }
                else { Button("Pause for 5 Minutes") { settings.pause(for: 300) } }
            }
        }
    }
}

private struct AutoSwitchSettingsView: View {
    @ObservedObject var state: AppState
    @ObservedObject private var settings: SettingsManager

    init(state: AppState) {
        self.state = state
        settings = state.settings
    }

    var body: some View {
        SettingBlock("Automatic correction", detail: "QuarkSwitch changes a word only when the converted version scores clearly higher than the original.") {
            CorrectionExampleView()
            Toggle("Correct wrong-layout words automatically", isOn: $settings.isAutoSwitchEnabled)
        }
        Divider()
        SettingBlock("Confidence threshold", detail: "Higher confidence reduces false corrections but may miss uncommon words.") {
            HStack {
                Text("Conservative").font(.callout).foregroundStyle(.secondary)
                Slider(value: $settings.sensitivity, in: 0...1)
                Text("Strict").font(.callout).foregroundStyle(.secondary)
            }
            Text("Current threshold: \(Int(settings.sensitivity * 100))%")
                .font(.caption).foregroundStyle(.secondary)
        }
        Divider()
        SettingBlock("How it decides") {
            Label("Local dictionaries and frequency hints", systemImage: "books.vertical")
            Label("Character n-grams and spelling heuristics", systemImage: "textformat.abc")
            Label("Apple Natural Language confidence", systemImage: "apple.intelligence")
            Label("Your exceptions and Undo choices", systemImage: "brain.head.profile")
        }
        .labelStyle(.titleAndIcon)
    }
}

private struct HotkeysSettingsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        SettingBlock("Global shortcuts", detail: "Shortcuts work whenever Input Monitoring is granted. They are intercepted by the same event tap used for word boundaries.") {
            ForEach(state.hotkeys.shortcuts) { shortcut in
                HStack {
                    Text(shortcut.title)
                    Spacer()
                    Text(shortcut.displayValue)
                        .font(.system(.body, design: .monospaced, weight: .medium))
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }
                .padding(.vertical, 4)
            }
        }
        Divider()
        SettingBlock("Undo") {
            HStack {
                Text("Undo the latest automatic correction")
                Spacer()
                Text("⌘ Z")
                    .font(.system(.body, design: .monospaced, weight: .medium))
            }
            Text("Undo is handled only for the latest correction, in the same app, for eight seconds. The original token is then learned as an exception.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
}

private struct LanguagesSettingsView: View {
    var body: some View {
        SettingBlock("Enabled layout pair") {
            HStack(spacing: 12) {
                LanguageBadge(code: "EN", name: "English QWERTY")
                Image(systemName: "arrow.left.arrow.right").foregroundStyle(.secondary)
                LanguageBadge(code: "RU", name: "Russian ЙЦУКЕН")
            }
        }
        Divider()
        SettingBlock("Character handling", detail: "Conversion follows physical key positions and preserves lowercase, uppercase, Shift punctuation, and Caps Lock output.") {
            Text("qwerty → йцукен")
            Text("QWERTY → ЙЦУКЕН")
            Text("[];’,./ → хъжэбю.")
        }
        .fontDesign(.monospaced)
    }
}

private struct LanguageBadge: View {
    let code: String
    let name: String

    var body: some View {
        HStack(spacing: 10) {
            Text(code).font(.headline).foregroundStyle(.tint)
            Text(name)
        }
        .padding(.horizontal, 13).padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 9))
    }
}

private struct ExceptionsSettingsView: View {
    @ObservedObject var manager: ExceptionManager
    @State private var newWord = ""

    var body: some View {
        SettingBlock("Never correct these words", detail: "Exceptions are stored only on this Mac. Undoing a correction adds its original token here.") {
            HStack {
                TextField("Add a word", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(add)
                Button("Add", action: add).disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        Divider()
        if manager.words.isEmpty {
            ContentUnavailableView("No Exceptions", systemImage: "text.badge.plus", description: Text("Add product names, abbreviations, or uncommon words you use."))
        } else {
            ForEach(manager.words, id: \.self) { word in
                HStack {
                    Text(word)
                    Spacer()
                    Button("Remove", systemImage: "minus.circle") { manager.remove(word) }
                        .labelStyle(.iconOnly).buttonStyle(.plain)
                        .accessibilityLabel("Remove \(word)")
                }
                Divider()
            }
        }
    }

    private func add() {
        manager.add(newWord)
        newWord = ""
    }
}

private struct ApplicationsSettingsView: View {
    @ObservedObject var filter: ApplicationFilter
    @State private var bundleIdentifier = ""

    var body: some View {
        SettingBlock("Application exclusions", detail: "Automatic correction is off in Terminal and iTerm by default. IDEs remain enabled and can be excluded here. Manual selection conversion remains available.") {
            ForEach(ApplicationFilter.knownApplications) { app in
                Toggle(isOn: Binding(
                    get: { filter.disabledBundleIdentifiers.contains(app.bundleIdentifier) },
                    set: { filter.setDisabled($0, bundleIdentifier: app.bundleIdentifier) }
                )) {
                    Label("Disable in \(app.name)", systemImage: app.systemImage)
                }
            }
        }
        Divider()
        SettingBlock("Add bundle identifier") {
            HStack {
                TextField("com.example.App", text: $bundleIdentifier)
                    .textFieldStyle(.roundedBorder).onSubmit(add)
                Button("Exclude", action: add).disabled(!bundleIdentifier.contains("."))
            }
        }
        let custom = filter.disabledBundleIdentifiers.subtracting(ApplicationFilter.knownApplications.map(\.bundleIdentifier))
        ForEach(custom.sorted(), id: \.self) { identifier in
            HStack {
                Text(identifier).fontDesign(.monospaced)
                Spacer()
                Button("Remove") { filter.remove(bundleIdentifier: identifier) }
            }
        }
    }

    private func add() {
        filter.add(bundleIdentifier: bundleIdentifier)
        bundleIdentifier = ""
    }
}

private struct PrivacySettingsView: View {
    @ObservedObject var state: AppState
    @ObservedObject private var permissions: PermissionManager

    init(state: AppState) {
        self.state = state
        permissions = state.permissions
    }

    var body: some View {
        SettingBlock("Permissions", detail: "Both permissions are required for automatic cross-application correction.") {
            PermissionRow(title: "Accessibility",
                          detail: "Replace only a confirmed wrong-layout word.",
                          isGranted: permissions.hasAccessibility,
                          action: permissions.requestAccessibility)
            PermissionRow(title: "Input Monitoring",
                          detail: "Read only a transient current-word buffer.",
                          isGranted: permissions.hasInputMonitoring,
                          action: permissions.requestInputMonitoring)
            if permissions.allGranted {
                HStack {
                    Label(state.operationalStatus.title, systemImage: state.operationalStatus.systemImage)
                        .foregroundStyle(state.operationalStatus == .active ? Color.green : Color.orange)
                    Spacer()
                    Button("Restart Monitor") { state.keyboardMonitor.restartIfPossible() }
                }
                .padding(.top, 4)
            }
        }
        Divider()
        SettingBlock("Privacy guarantees") {
            PrivacyPoint(icon: "lock.shield", title: "Secure fields are skipped", detail: "The buffer is cleared before any password or protected field is processed.")
            PrivacyPoint(icon: "network.slash", title: "No network service", detail: "Detection, learning, and statistics stay on this Mac.")
            PrivacyPoint(icon: "text.line.first.and.arrowtriangle.forward", title: "No typing history", detail: "Only the current or most recent word remains briefly in memory; stored data is aggregate counts and exceptions.")
        }
    }
}

private struct PrivacyPoint: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).frame(width: 22).foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.medium)
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }
        }.padding(.vertical, 4)
    }
}

private struct StatisticsSettingsView: View {
    @ObservedObject var manager: StatisticsManager
    @State private var showingReset = false

    var body: some View {
        let today = manager.today
        let week = manager.thisWeek

        SettingBlock("Local activity", detail: "Only aggregate counts are recorded. No words or application names are included.") {
            HStack(alignment: .firstTextBaseline, spacing: 36) {
                StatisticValue(value: today.corrections, label: "Today")
                StatisticValue(value: week.corrections, label: "This week")
                Spacer()
            }
        }
        Divider()
        SettingBlock("Direction this week") {
            HStack(spacing: 28) {
                Label("\(week.englishToRussian)  EN → RU", systemImage: "arrow.right")
                Label("\(week.russianToEnglish)  RU → EN", systemImage: "arrow.left")
                Label("\(week.undoCount)  Undone", systemImage: "arrow.uturn.backward")
            }
        }
        Divider()
        Button("Reset Statistics…", role: .destructive) { showingReset = true }
            .alert("Reset local statistics?", isPresented: $showingReset) {
                Button("Reset", role: .destructive) { manager.reset() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes aggregate counts. Exceptions and settings are not changed.")
            }
    }
}

private struct StatisticValue: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value, format: .number).font(.system(size: 34, weight: .semibold, design: .rounded))
            Text(label).foregroundStyle(.secondary)
        }
    }
}
