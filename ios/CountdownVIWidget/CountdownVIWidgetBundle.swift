import SwiftUI
import WidgetKit

@main
struct CountdownVIWidgetBundle: WidgetBundle {
    var body: some Widget {
        // EXPERIMENT (T-027c): build 22 works with only the Live Activity registered.
        // Register a static, small-only probe before it, in the original widget's position,
        // to isolate coexistence from the full countdown's timeline and rendering code.
        // CountdownWidget.swift remains compiled but its widget is not registered.
        CountdownProbeWidget()
        CountdownLiveActivity()
    }
}
