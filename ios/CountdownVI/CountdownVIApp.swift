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
                    // The Live Activity sync lives in CountdownView, which also shows its start button.
                    guard scenePhase == .active else { return }
                    await NotificationScheduler.rescheduleIfAuthorized()
                }
        }
    }
}
