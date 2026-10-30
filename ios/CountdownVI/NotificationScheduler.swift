import Foundation
import OSLog
import UserNotifications

/// Shows milestone banners while the app is in the foreground (iOS hides them by default).
/// The notification center keeps only a weak reference, hence the shared instance.
final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ForegroundNotificationPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

/// Schedules the release milestones as local notifications (D-001: no remote push).
@MainActor
enum NotificationScheduler {
    private static let logger = Logger(subsystem: "com.countdownvi.app", category: "Notifications")
    private static let identifierPrefix = "milestone."

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Shows the system prompt (only the first time) and schedules if the user allows.
    static func requestAuthorizationAndSchedule() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            guard granted else { return }
        } catch {
            logger.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
            return
        }
        await reschedule()
    }

    /// Idempotent: safe to call on every launch. Does nothing without permission.
    static func rescheduleIfAuthorized() async {
        switch await authorizationStatus() {
        case .authorized, .provisional, .ephemeral:
            await reschedule()
        default:
            return
        }
    }

    private static func reschedule(now: Date = .now) async {
        let center = UNUserNotificationCenter.current()
        let milestones = ReleaseConfig.Milestone.allCases
        center.removePendingNotificationRequests(withIdentifiers: milestones.map(identifier(for:)))

        for milestone in milestones {
            let interval = milestone.fireDate.timeIntervalSince(now)
            guard interval > 0 else { continue }

            let content = UNMutableNotificationContent()
            content.title = milestone == .release ? "Chegou o dia!" : ReleaseConfig.gameTitle
            content.body = body(for: milestone)
            content.sound = .default

            // Time-interval trigger fires at the absolute instant, unaffected by time zone changes.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: identifier(for: milestone), content: content, trigger: trigger)
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule \(milestone.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private static func identifier(for milestone: ReleaseConfig.Milestone) -> String {
        identifierPrefix + milestone.rawValue
    }

    /// Copy is derived from the milestone offset, so ReleaseConfig stays the only place with values.
    private static func body(for milestone: ReleaseConfig.Milestone) -> String {
        let game = ReleaseConfig.gameTitle
        let interval = milestone.timeBeforeRelease
        guard interval > 0 else { return "\(game) já está disponível." }

        let days = Int(interval / 86_400)
        let hours = Int(interval / 3_600)
        let (count, unit) = days > 0
            ? (days, days == 1 ? "dia" : "dias")
            : (hours, hours == 1 ? "hora" : "horas")
        let verb = count == 1 ? "Falta" : "Faltam"
        return "\(verb) \(count) \(unit) para \(game)."
    }
}
