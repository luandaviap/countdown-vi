import SwiftUI
import WidgetKit

/// Home Screen / Lock Screen countdown. Unlike the Live Activity it never expires: the whole
/// timeline is precomputed, so it keeps counting without the app running (D-001, D-013).
struct CountdownWidget: Widget {
    let kind = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownTimelineProvider()) { entry in
            CountdownWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color.black }
        }
        .configurationDisplayName("Contagem \(ReleaseConfig.gameTitle)")
        .description("Dias até o lançamento.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
}

struct CountdownTimelineProvider: TimelineProvider {
    /// Caps the timeline size; with .atEnd WidgetKit asks for the next batch after the last entry.
    private static let maxEntries = 60

    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(CountdownEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let now = Date.now
        let entries = [CountdownEntry(date: now)]
            + DayCountdown.boundaries(after: now).prefix(Self.maxEntries).map(CountdownEntry.init(date:))
        // After the release there is nothing left to schedule.
        let policy: TimelineReloadPolicy = now >= ReleaseConfig.releaseDate ? .never : .atEnd
        completion(Timeline(entries: entries, policy: policy))
    }
}

/// Same day rule as the app (D-010): days = max(0, ceil(remaining / 1 day) - 1), so the count
/// drops exactly at each boundary and the day clock always spans (0, 24h].
enum DayCountdown {
    private static let secondsPerDay: TimeInterval = 86_400

    static func days(at date: Date) -> Int {
        let remainingDays = ReleaseConfig.releaseDate.timeIntervalSince(date) / secondsPerDay
        return max(0, Int(remainingDays.rounded(.up)) - 1)
    }

    /// End of the current day's clock: the next instant at which `days(at:)` drops.
    static func nextBoundary(after date: Date) -> Date {
        ReleaseConfig.releaseDate.addingTimeInterval(-Double(days(at: date)) * secondsPerDay)
    }

    /// Ascending boundaries after `date` (releaseDate - k days for k = days...1), then the release.
    static func boundaries(after date: Date) -> [Date] {
        guard date < ReleaseConfig.releaseDate else { return [] }
        return stride(from: days(at: date), through: 0, by: -1).map {
            ReleaseConfig.releaseDate.addingTimeInterval(-Double($0) * secondsPerDay)
        }
    }
}

struct CountdownWidgetView: View {
    let entry: CountdownEntry

    @Environment(\.widgetFamily) private var family

    private var isReleased: Bool { entry.date >= ReleaseConfig.releaseDate }
    private var days: Int { DayCountdown.days(at: entry.date) }
    private var daysUnit: String { days == 1 ? "dia" : "dias" }

    var body: some View {
        content
            .foregroundStyle(.white)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(accessibilityText))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryRectangular: rectangular
        case .systemMedium: medium
        default: small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            title
            Spacer(minLength: 0)
            if isReleased {
                releasedText.font(.system(.title3, design: .rounded, weight: .bold))
            } else {
                dayCount(size: 44)
                dayClock.font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            provisionalNote
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var medium: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                title
                Text(ReleaseConfig.releaseDate, format: .dateTime.day().month(.wide).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                provisionalNote
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if isReleased {
                    releasedText.font(.system(.title2, design: .rounded, weight: .bold))
                } else {
                    dayCount(size: 56)
                    dayClock
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(ReleaseConfig.gameTitle)
                .font(.headline)
            if isReleased {
                releasedText
            } else {
                Text("\(days) \(daysUnit)")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                dayClock
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -2) {
                if isReleased {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.bold))
                } else {
                    Text("\(days)")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                    Text(daysUnit)
                        .font(.caption2)
                }
            }
        }
    }

    private var title: some View {
        Text(ReleaseConfig.gameTitle)
            .font(.system(.headline, design: .rounded, weight: .heavy))
    }

    private var releasedText: some View {
        Text("Disponível agora")
    }

    private func dayCount(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(days)")
                .font(.system(size: size, weight: .black, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(daysUnit)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }

    /// Self-updating clock for the current day; the range end is clamped so it stays valid.
    private var dayClock: some View {
        let end = DayCountdown.nextBoundary(after: entry.date)
        return Text(timerInterval: entry.date...max(entry.date, end), countsDown: true)
            .monospacedDigit()
    }

    @ViewBuilder
    private var provisionalNote: some View {
        if !ReleaseConfig.isDateVerified {
            Text("Data provisória")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var accessibilityText: String {
        let status = isReleased
            ? "\(ReleaseConfig.gameTitle) disponível agora"
            : "Faltam \(days) \(daysUnit) para \(ReleaseConfig.gameTitle)"
        return ReleaseConfig.isDateVerified ? status : "\(status). Data provisória"
    }
}

#Preview(as: .systemSmall) {
    CountdownWidget()
} timeline: {
    CountdownEntry(date: .now)
}
