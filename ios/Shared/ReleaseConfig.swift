import Foundation

/// Single source of truth for the release date. Never hardcode the date elsewhere.
enum ReleaseConfig {
    static let gameTitle = "GTA VI"

    /// PROVISIONAL and NOT VERIFIED. Must be confirmed by the user before any release.
    /// Midnight US Eastern (EST, UTC-5) is also an assumption.
    static let releaseDateISO8601 = "2026-11-19T00:00:00-05:00"

    /// Flip to `true` only after the user confirms the official date.
    static let isDateVerified = false

    static let releaseDate: Date = {
        guard let date = ISO8601DateFormatter().date(from: releaseDateISO8601) else {
            preconditionFailure("Invalid ReleaseConfig.releaseDateISO8601: \(releaseDateISO8601)")
        }
        return date
    }()

    /// The home progress bar covers only this final stretch before the release.
    static let progressWindow: TimeInterval = 30 * 86_400

    /// Local notification milestones, as offsets before `releaseDate`.
    enum Milestone: String, CaseIterable {
        case thirtyDays
        case sevenDays
        case oneDay
        case oneHour
        case release

        var timeBeforeRelease: TimeInterval {
            switch self {
            case .thirtyDays: 30 * 86_400
            case .sevenDays: 7 * 86_400
            case .oneDay: 86_400
            case .oneHour: 3_600
            case .release: 0
            }
        }

        var fireDate: Date {
            releaseDate.addingTimeInterval(-timeBeforeRelease)
        }
    }
}
