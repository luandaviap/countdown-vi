import ActivityKit
import SwiftUI
import WidgetKit

struct CountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownActivityAttributes.self) { context in
            LockScreenCountdownView(title: context.attributes.title, releaseDate: context.state.releaseDate)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.title)
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.releaseDate, format: .dateTime.day().month(.abbreviated))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    CountdownTimerText(releaseDate: context.state.releaseDate)
                        .font(.system(.title, design: .rounded, weight: .bold))
                }
            } compactLeading: {
                Text("VI")
                    .font(.system(.caption, design: .rounded, weight: .heavy))
            } compactTrailing: {
                // Timer text reserves its widest layout by default; above 24h it shows total hours
                // ("480:12:03", 9 glyphs), so pin a width that fits that at caption2 monospaced digits.
                CountdownTimerText(releaseDate: context.state.releaseDate)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.trailing)
                    .frame(width: 56, alignment: .trailing)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}

private struct LockScreenCountdownView: View {
    let title: String
    let releaseDate: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .heavy))
                Text(releaseDate, format: .dateTime.day().month(.wide).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            CountdownTimerText(releaseDate: releaseDate)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .foregroundStyle(.white)
    }
}

/// Self-updating countdown; no app process or server needed (D-001).
/// The upper bound is clamped so the range stays valid after the release date.
private struct CountdownTimerText: View {
    let releaseDate: Date

    var body: some View {
        let now = Date.now
        Text(timerInterval: now...max(now, releaseDate), countsDown: true)
            .monospacedDigit()
    }
}
