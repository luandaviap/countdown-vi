import SwiftUI
import WidgetKit

@main
struct CountdownVIWidgetBundle: WidgetBundle {
    var body: some Widget {
        // EXPERIMENT (T-027c): only the Live Activity is registered, exactly as in build 10, the last
        // build that works on the user's iPhone. CountdownWidget.swift is still compiled but not
        // registered, to test whether registering it takes the whole extension down on iOS 26.
        // Restore `CountdownWidget()` here once the cause is known.
        CountdownLiveActivity()
    }
}
