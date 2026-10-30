import ActivityKit
import Foundation

/// Shared by the app (starts/updates the activity locally) and the widget extension (renders it).
/// No push token: per D-001 the activity is driven only on device.
struct CountdownActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var releaseDate: Date
    }

    var title: String
}
