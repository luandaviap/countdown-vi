import SwiftUI
import UserNotifications

@main
struct CountdownVIApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = ForegroundNotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            CountdownView()
                .preferredColorScheme(.dark)
                .task(id: scenePhase) {
                    // Activity.request only works in the foreground; also restarts the activity
                    // after the system ends it (Live Activities have a limited lifetime).
                    guard scenePhase == .active else { return }
                    await LiveActivityController.sync()
                    await NotificationScheduler.rescheduleIfAuthorized()
                }
        }
    }
}
