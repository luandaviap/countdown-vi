import ActivityKit
import SwiftUI
import WidgetKit

struct CountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownActivityAttributes.self) { context in
            LockScreenCountdownView(
                title: context.attributes.title,
                state: context.state,
                isStale: context.isStale
            )
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
                    HStack(alignment: .firstTextBaseline) {
                        if !context.isStale {
                            DaysLabel(days: context.state.days)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                        }
                        Spacer()
                        CountdownTimerText(releaseDate: context.state.releaseDate)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.trailing)
                    }
                }
            } compactLeading: {
                // TODO(T-024): replace with the palm glyph from assets/design/palm-glyph.svg.
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.isStale {
                    // Fixed "Nd" is no longer true: fall back to the self-updating timer.
                    // Timer text reserves its widest layout by default; above 24h it shows total
                    // hours ("480:12:03", 9 glyphs), so pin a width that fits that at caption2.
                    CountdownTimerText(releaseDate: context.state.releaseDate)
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 56, alignment: .trailing)
                } else {
                    Text(verbatim: "\(context.state.days)d")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .accessibilityLabel(Text(DaysLabel.text(for: context.state.days)))
                }
            } minimal: {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

private struct LockScreenCountdownView: View {
    let title: String
    let state: CountdownActivityAttributes.ContentState
    let isStale: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                    Text(state.releaseDate, format: .dateTime.day().month(.wide).year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if !isStale {
                        DaysLabel(days: state.days)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    CountdownTimerText(releaseDate: state.releaseDate)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.trailing)
                }
            }
            // TODO(remover): D-016 option 2 experiment, to see on device how iOS formats a relative
            // date (language, units, rounding). Delete this line once the user has seen it.
            Text(state.releaseDate, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .foregroundStyle(.white)
    }
}

/// Fixed "N dias" snapshot; callers hide it when the content is stale (D-016).
private struct DaysLabel: View {
    let days: Int

    static func text(for days: Int) -> String {
        "\(days) \(days == 1 ? "dia" : "dias")"
    }

    var body: some View {
        Text(Self.text(for: days))
            .monospacedDigit()
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
