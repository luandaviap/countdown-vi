import ActivityKit
import Foundation
import OSLog

/// Starts, reuses and ends the countdown Live Activity entirely on device (D-001: pushType nil).
@MainActor
enum LiveActivityController {
    private static let logger = Logger(subsystem: "com.countdownvi.app", category: "LiveActivity")

    /// Idempotent: call whenever the app becomes active.
    static func sync(now: Date = .now) async {
        let releaseDate = ReleaseConfig.releaseDate
        let running = Activity<CountdownActivityAttributes>.activities.filter {
            $0.activityState == .active || $0.activityState == .stale
        }

        guard now < releaseDate else {
            for activity in running {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }

        let content = ActivityContent(
            state: CountdownActivityAttributes.ContentState(releaseDate: releaseDate),
            staleDate: releaseDate
        )

        if let current = running.first {
            for duplicate in running.dropFirst() {
                await duplicate.end(nil, dismissalPolicy: .immediate)
            }
            if current.content.state != content.state {
                await current.update(content)
            }
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("Live Activities disabled by the user; skipping request")
            return
        }

        do {
            _ = try Activity.request(
                attributes: CountdownActivityAttributes(title: ReleaseConfig.gameTitle),
                content: content,
                pushType: nil
            )
        } catch {
            // The app keeps working without the activity (e.g. system limit reached).
            logger.error("Live Activity request failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
