import ActivityKit
import Foundation
import OSLog

/// Starts, reuses and ends the countdown Live Activity entirely on device (D-001: pushType nil).
@MainActor
enum LiveActivityController {
    private static let logger = Logger(subsystem: "com.countdownvi.app", category: "LiveActivity")

    // TODO(remover-diagnostico): surfaced on the home screen for on-device debugging (T-027).
    /// Full text of the last Activity.request failure, if any (kept until the app is relaunched).
    private(set) static var lastError: String?
    /// What the last sync did: "request ok", "update", "pulado: ...", "request falhou".
    private(set) static var lastAction = "nenhuma"

    /// Whether the "Ativar Live Activity" button can help: activities allowed and none running.
    static var canStartActivity: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
            && !Activity<CountdownActivityAttributes>.activities.contains {
                $0.activityState == .active || $0.activityState == .stale
            }
    }

    /// Idempotent: call whenever the app becomes active or the user taps the start button
    /// (both are foreground, which Activity.request requires).
    static func sync(now: Date = .now) async {
        let releaseDate = ReleaseConfig.releaseDate
        let running = Activity<CountdownActivityAttributes>.activities.filter {
            $0.activityState == .active || $0.activityState == .stale
        }

        guard now < releaseDate else {
            for activity in running {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            lastAction = "encerrada: após a data"
            return
        }

        // The fixed day count is only valid until the next day boundary; marking the content stale
        // there makes the views drop the label instead of showing a wrong day (D-016).
        let state = CountdownActivityAttributes.ContentState(releaseDate: releaseDate, now: now)
        let content = ActivityContent(state: state, staleDate: state.nextDayBoundary)

        if let current = running.first {
            for duplicate in running.dropFirst() {
                await duplicate.end(nil, dismissalPolicy: .immediate)
            }
            // Always refresh: even with the same state, the staleDate moves forward.
            await current.update(content)
            lastAction = "update (\(current.activityState))"
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("Live Activities disabled by the user; skipping request")
            lastAction = "pulado: Live Activities desativadas"
            return
        }

        do {
            let activity = try Activity.request(
                attributes: CountdownActivityAttributes(title: ReleaseConfig.gameTitle),
                content: content,
                pushType: nil
            )
            lastAction = "request ok (\(activity.activityState))"
        } catch {
            // The app keeps working without the activity (e.g. system limit reached).
            logger.error("Live Activity request failed: \(error.localizedDescription, privacy: .public)")
            lastAction = "request falhou"
            lastError = "\(error.localizedDescription) | \(String(reflecting: error))"
        }
    }
}
