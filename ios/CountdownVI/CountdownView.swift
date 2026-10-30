import SwiftUI
import UIKit
import UserNotifications

struct CountdownView: View {
    private static let secondsPerDay: TimeInterval = 86_400

    private let releaseDate = ReleaseConfig.releaseDate

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    /// Drives the opt-in button (never asked) and the Settings shortcut (denied).
    @State private var notificationStatus: UNAuthorizationStatus?

    var body: some View {
        // Text(timerInterval:) ticks the hours/minutes/seconds on its own; the view only
        // needs to re-render when the day count changes, so the timeline fires at day boundaries.
        TimelineView(.explicit(dayBoundaries(from: .now))) { context in
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
        let days = wholeDaysRemaining(from: now)
        let dayBoundary = releaseDate.addingTimeInterval(-Double(days) * Self.secondsPerDay)

        return VStack(spacing: 8) {
            Text("\(days)")
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 72 : 96, weight: .black, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(days == 1 ? "dia" : "dias")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(timerInterval: now...max(now, dayBoundary), countsDown: true)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Faltam \(days) dias para o lançamento"))
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

    /// Days shown next to the timer. Rounds up then subtracts one, so the count drops at the exact
    /// boundary instant and the timer range is always in (0, 24h], never empty before the release.
    private func wholeDaysRemaining(from now: Date) -> Int {
        let remainingDays = releaseDate.timeIntervalSince(now) / Self.secondsPerDay
        return max(0, Int(remainingDays.rounded(.up)) - 1)
    }

    /// Now, then the ascending instants at which the day count drops (releaseDate - k days for
    /// k = days...1), ending at the release itself.
    private func dayBoundaries(from now: Date) -> [Date] {
        let days = wholeDaysRemaining(from: now)
        return [now] + stride(from: days, through: 0, by: -1).map {
            releaseDate.addingTimeInterval(-Double($0) * Self.secondsPerDay)
        }
    }
}

#Preview {
    CountdownView()
        .preferredColorScheme(.dark)
}
