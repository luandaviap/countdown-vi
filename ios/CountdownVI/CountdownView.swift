import SwiftUI
import UIKit
import UserNotifications

struct CountdownView: View {
    private let releaseDate = ReleaseConfig.releaseDate

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    /// Drives the opt-in button (never asked) and the Settings shortcut (denied).
    @State private var notificationStatus: UNAuthorizationStatus?

    var body: some View {
        // Days and clock come from the same whole-second count, so they can never disagree
        // and the clock never shows 24:00:00. Ticks are anchored to whole seconds before the release.
        TimelineView(.periodic(from: tickAnchor(now: .now), by: 1)) { context in
            VStack(spacing: 32) {
                Text(ReleaseConfig.gameTitle)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .accessibilityAddTraits(.isHeader)

                if context.date >= releaseDate {
                    Text("Disponível agora")
                        .font(.system(.title, design: .rounded, weight: .bold))
                } else {
                    countdown(now: context.date)
                }

                releaseInfo

                if context.date < releaseDate {
                    switch notificationStatus {
                    case .notDetermined: notificationOptInButton
                    case .denied: notificationSettingsShortcut
                    default: EmptyView()
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .foregroundStyle(.white)
        }
        .task(id: scenePhase) {
            // Re-read on every activation so returning from Settings updates the UI.
            guard scenePhase == .active else { return }
            notificationStatus = await NotificationScheduler.authorizationStatus()
        }
    }

    private var notificationOptInButton: some View {
        Button {
            Task {
                await NotificationScheduler.requestAuthorizationAndSchedule()
                notificationStatus = await NotificationScheduler.authorizationStatus()
            }
        } label: {
            Label("Avisar nos marcos", systemImage: "bell.badge")
                .font(.system(.headline, design: .rounded))
        }
        .buttonStyle(.borderedProminent)
        .tint(.white)
        .foregroundStyle(.black)
        .accessibilityHint(Text("Receba avisos conforme o lançamento se aproxima"))
    }

    private var notificationSettingsShortcut: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        } label: {
            Label("Avisos desativados. Ativar nos Ajustes", systemImage: "bell.slash")
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .accessibilityHint(Text("Abre os Ajustes do app"))
    }

    private func countdown(now: Date) -> some View {
        let timeLeft = TimeLeft(totalSeconds: Int(releaseDate.timeIntervalSince(now).rounded()))

        return VStack(spacing: 8) {
            Text("\(timeLeft.days)")
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 72 : 96, weight: .black, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText(countsDown: true))
            Text(timeLeft.days == 1 ? "dia" : "dias")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(verbatim: timeLeft.clock)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .padding(.top, 8)
        }
        .animation(reduceMotion ? nil : .snappy, value: timeLeft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Faltam \(timeLeft.days) dias para o lançamento"))
    }

    private var releaseInfo: some View {
        VStack(spacing: 4) {
            Text(releaseDate, format: .dateTime.day().month(.wide).year())
                .font(.headline)
            if !ReleaseConfig.isDateVerified {
                Text("Data provisória")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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

    var clock: String { String(format: "%02d:%02d:%02d", hours, minutes, seconds) }
}

#Preview {
    CountdownView()
        .preferredColorScheme(.dark)
}
