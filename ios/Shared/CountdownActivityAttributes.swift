import ActivityKit
import Foundation

/// Shared by the app (starts/updates the activity locally) and the widget extension (renders it).
/// No push token: per D-001 the activity is driven only on device.
struct CountdownActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var releaseDate: Date
        /// Fixed "N dias" label (D-016). Only true until `nextDayBoundary`, which the app passes as
        /// the content's staleDate; the views hide it once `context.isStale`.
        var days: Int
    }

    var title: String
}

extension CountdownActivityAttributes.ContentState {
    private static let secondsPerDay: TimeInterval = 86_400

    /// Snapshot at `now` using the D-010 rule: days = max(0, ceil(remaining / 1 day) - 1).
    init(releaseDate: Date, now: Date) {
        let remainingDays = releaseDate.timeIntervalSince(now) / Self.secondsPerDay
        self.init(releaseDate: releaseDate, days: max(0, Int(remainingDays.rounded(.up)) - 1))
    }

    /// The instant at which `days` stops being correct.
    var nextDayBoundary: Date {
        releaseDate.addingTimeInterval(-Double(days) * Self.secondsPerDay)
    }
}
