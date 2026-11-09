import SwiftUI
import WidgetKit

@main
struct CountdownVIWidgetBundle: WidgetBundle {
    var body: some Widget {
        // EXPERIMENT (T-027c): restore the build 22 registration, confirmed working on device.
        // The static probe now lives in a separate extension, so it is not discovered through
        // this bundle. Keep this extension's bundle identifier and Live Activity code unchanged.
        CountdownLiveActivity()
    }
}
