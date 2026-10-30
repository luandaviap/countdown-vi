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
                CountdownTimerText(releaseDate: context.state.releaseDate)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .frame(maxWidth: 64)
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
