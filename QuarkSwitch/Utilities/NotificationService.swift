import AppKit
import UserNotifications

@MainActor
final class NotificationService {
    func correctionCompleted(settings: SettingsManager) {
        if settings.playSound { NSSound(named: "Tink")?.play() }
        guard settings.showNotification else { return }

        let content = UNMutableNotificationContent()
        content.title = "Layout corrected"
        content.body = "The last word was corrected. Press Command–Z to undo."
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
