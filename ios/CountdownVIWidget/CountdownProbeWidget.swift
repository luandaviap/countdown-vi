import SwiftUI
import WidgetKit

/// Temporary T-027c probe: a standard widget and Live Activity in the same extension.
/// No countdown, release-date logic, network, shared storage, or preview macros.
struct CountdownProbeWidget: Widget {
    // Preserve the original widget kind so this experiment does not also change its identity.
    let kind = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProbeProvider()) { _ in
            Text("Widget de teste")
                .foregroundStyle(.white)
                .containerBackground(for: .widget) { Color.black }
        }
        .configurationDisplayName("Contagem \(ReleaseConfig.gameTitle)")
        .description("Teste temporário de coexistência com a Live Activity.")
        .supportedFamilies([.systemSmall])
    }
}

private struct CountdownProbeEntry: TimelineEntry {
    let date: Date
}

private struct CountdownProbeProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownProbeEntry {
        CountdownProbeEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownProbeEntry) -> Void) {
        completion(CountdownProbeEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownProbeEntry>) -> Void) {
        completion(Timeline(entries: [CountdownProbeEntry(date: .now)], policy: .never))
    }
}
