import SwiftUI
import UIKit
import UserNotifications

/// Home screen, design v2 (D-012): sunset background, glass blocks, 30-day progress bar.
/// Text sits on the calm upper sky; buttons sit on the water at the bottom, over a dark band,
/// so nothing overlaps the sun or the palms.
struct CountdownView: View {
    private let releaseDate = ReleaseConfig.releaseDate

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    /// Drives the opt-in button (never asked) and the Settings shortcut (denied).
    @State private var notificationStatus: UNAuthorizationStatus?
    /// Starts hidden so the button does not flash before the first sync.
    @State private var canStartLiveActivity = false

    @ScaledMetric(relativeTo: .largeTitle) private var numberSize: CGFloat = 36
    @ScaledMetric(relativeTo: .caption2) private var unitSize: CGFloat = 10

    var body: some View {
        // Days and clock come from the same whole-second count (D-010), so they can never disagree
        // and never show 24:00:00. Ticks are anchored to whole seconds before the release.
        TimelineView(.periodic(from: tickAnchor(now: .now), by: 1)) { context in
            // Full layout when it fits; scrolls at the largest accessibility text sizes.
            ViewThatFits(in: .vertical) {
                layout(at: context.date)
                ScrollView { layout(at: context.date) }
            }
        }
        .foregroundStyle(Theme.Palette.textPrimary)
        .background { background }
        .task(id: scenePhase) {
            // Re-read on every activation so returning from Settings updates the UI. The sync also
            // (re)starts the Live Activity, which only works in the foreground (D-006).
            guard scenePhase == .active else { return }
            await LiveActivityController.sync()
            canStartLiveActivity = LiveActivityController.canStartActivity
            notificationStatus = await NotificationScheduler.authorizationStatus()
        }
    }

    // MARK: - Layout

    private func layout(at date: Date) -> some View {
        let timeLeft = TimeLeft(totalSeconds: max(0, Int(releaseDate.timeIntervalSince(date).rounded())))

        return VStack(spacing: 0) {
            sky(timeLeft: timeLeft, isReleased: date >= releaseDate)
                .padding(.horizontal, Theme.Metrics.sideMargin)
                .padding(.top, 16)
            Spacer(minLength: Theme.Metrics.sectionSpacing)
            if date < releaseDate {
                actions
            }
        }
    }

    private func sky(timeLeft: TimeLeft, isReleased: Bool) -> some View {
        VStack(spacing: Theme.Metrics.sectionSpacing) {
            VStack(spacing: 6) {
                Text(AppCopy.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(AppCopy.subtitle)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if isReleased {
                Text(AppCopy.released)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background { glass }
            } else {
                blocks(timeLeft)
            }

            VStack(spacing: 16) {
                progressBar(remainingSeconds: timeLeft.totalSeconds)
                releaseInfo
            }
        }
        .shadow(color: Theme.Palette.night.opacity(0.35), radius: 6, y: 1)
    }

    // MARK: - Countdown blocks

    @ViewBuilder
    private func blocks(_ timeLeft: TimeLeft) -> some View {
        let days = glassBlock(value: "\(timeLeft.days)", unit: AppCopy.unitDays)
        let hours = glassBlock(value: Self.twoDigits(timeLeft.hours), unit: AppCopy.unitHours)
        let minutes = glassBlock(value: Self.twoDigits(timeLeft.minutes), unit: AppCopy.unitMinutes)
        let seconds = glassBlock(value: Self.twoDigits(timeLeft.seconds), unit: AppCopy.unitSeconds)

        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: Theme.Metrics.cardSpacing) {
                    HStack(spacing: Theme.Metrics.cardSpacing) { days; hours }
                    HStack(spacing: Theme.Metrics.cardSpacing) { minutes; seconds }
                }
            } else {
                HStack(spacing: Theme.Metrics.cardSpacing) { days; hours; minutes; seconds }
            }
        }
        .animation(reduceMotion ? nil : .snappy, value: timeLeft)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(AppCopy.timeLeft(days: timeLeft.days, hours: timeLeft.hours, minutes: timeLeft.minutes)))
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func glassBlock(value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(verbatim: value)
                .font(.system(size: numberSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText(countsDown: true))
            Text(unit.uppercased())
                .font(.system(size: unitSize, weight: .semibold, design: .rounded))
                .tracking(1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .background { glass }
    }

    /// Glass card: thin material + 12% white + 30% white border; solid when Reduce Transparency is on.
    private var glass: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Metrics.cardRadius, style: .continuous)
        return ZStack {
            if reduceTransparency {
                shape.fill(Theme.Glass.solidFill)
            } else {
                shape.fill(.ultraThinMaterial)
                shape.fill(Theme.Glass.fill)
            }
            shape.strokeBorder(Theme.Glass.border, lineWidth: Theme.Glass.borderWidth)
        }
    }

    // MARK: - Progress and date

    private func progressBar(remainingSeconds: Int) -> some View {
        let fraction = min(max(1 - Double(remainingSeconds) / ReleaseConfig.progressWindow, 0), 1)
        let windowDays = Int(ReleaseConfig.progressWindow / 86_400)

        return Capsule()
            .fill(Theme.Palette.progressTrack)
            .frame(height: Theme.Metrics.progressHeight)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Theme.progressGradient)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .accessibilityElement()
            .accessibilityLabel(Text(AppCopy.progressLabel(windowDays: windowDays)))
            .accessibilityValue(Text(AppCopy.progressValue(percent: Int((fraction * 100).rounded()))))
    }

    private var releaseInfo: some View {
        VStack(spacing: 4) {
            Text(releaseDate, format: .dateTime.day().month(.wide).year())
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            if !ReleaseConfig.isDateVerified {
                Text(AppCopy.provisionalDate)
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions (bottom band over the water)

    @ViewBuilder
    private var actions: some View {
        let showsNotificationControl = notificationStatus == .notDetermined || notificationStatus == .denied
        if canStartLiveActivity || showsNotificationControl {
            VStack(spacing: 12) {
                if canStartLiveActivity {
                    liveActivityButton
                }
                switch notificationStatus {
                case .notDetermined: notificationOptInButton
                case .denied: notificationSettingsShortcut
                default: EmptyView()
                }
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, Theme.Metrics.sideMargin)
            .padding(.top, 40)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background { bottomBand }
        }
    }

    /// Dark translucent band behind the buttons, so they keep contrast over the bright water.
    private var bottomBand: some View {
        Group {
            if reduceTransparency {
                Theme.Palette.night
            } else {
                LinearGradient(
                    stops: [
                        .init(color: Theme.Palette.night.opacity(0), location: 0),
                        .init(color: Theme.Palette.night.opacity(0.8), location: 0.35),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var liveActivityButton: some View {
        Button {
            Task {
                await LiveActivityController.sync()
                canStartLiveActivity = LiveActivityController.canStartActivity
            }
        } label: {
            Text(AppCopy.startLiveActivity)
                .font(.system(.headline, design: .rounded))
                // Dark text: white on the orange end of the gradient would fall below 4.5:1.
                .foregroundStyle(Theme.Palette.night)
                .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minButtonHeight)
                .padding(.horizontal, 20)
                .background(Theme.buttonGradient, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(AppCopy.startLiveActivityHint))
    }

    private var notificationOptInButton: some View {
        Button {
            Task {
                await NotificationScheduler.requestAuthorizationAndSchedule()
                notificationStatus = await NotificationScheduler.authorizationStatus()
            }
        } label: {
            Label(AppCopy.notifyMilestones, systemImage: "bell.badge")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minButtonHeight)
                .padding(.horizontal, 20)
                .background(Theme.Palette.night, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.Glass.border, lineWidth: Theme.Glass.borderWidth))
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(AppCopy.notifyMilestonesHint))
    }

    private var notificationSettingsShortcut: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        } label: {
            Label(AppCopy.notificationsDenied, systemImage: "bell.slash")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .frame(minHeight: Theme.Metrics.minButtonHeight)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.Palette.textSecondary)
        .accessibilityHint(Text(AppCopy.notificationsDeniedHint))
    }

    // MARK: - Background

    /// Full-screen sunset, bottom-aligned, under the safe areas. A soft dark scrim on the upper sky
    /// keeps the text there at >= 4.5:1; it fades out before the sun.
    private var background: some View {
        Theme.skyGradient
            .overlay(alignment: .bottom) {
                Image(decorative: "SunsetBackground")
                    .resizable()
                    .scaledToFill()
            }
            .overlay {
                if reduceTransparency {
                    Theme.Palette.night.opacity(0.5)
                } else {
                    LinearGradient(
                        stops: [
                            .init(color: Theme.Palette.night.opacity(0.45), location: 0),
                            .init(color: Theme.Palette.night.opacity(0.35), location: 0.45),
                            .init(color: .clear, location: 0.62),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .clipped()
            .ignoresSafeArea()
    }

    // MARK: - Helpers

    private static func twoDigits(_ value: Int) -> String {
        String(format: "%02d", value)
    }

    /// A past instant a whole number of seconds before the release, so every tick lands on an exact
    /// second of the countdown (and one tick lands exactly on the release).
    private func tickAnchor(now: Date) -> Date {
        releaseDate.addingTimeInterval(-releaseDate.timeIntervalSince(now).rounded(.up))
    }
}

/// Whole seconds left, split into days and a clock that stays within 00:00:00...23:59:59.
private struct TimeLeft: Equatable {
    let totalSeconds: Int

    var days: Int { totalSeconds / 86_400 }
    var hours: Int { totalSeconds % 86_400 / 3_600 }
    var minutes: Int { totalSeconds % 3_600 / 60 }
    var seconds: Int { totalSeconds % 60 }
}

#Preview {
    CountdownView()
        .preferredColorScheme(.dark)
}
