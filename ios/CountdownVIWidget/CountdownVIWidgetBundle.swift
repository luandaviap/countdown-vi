import SwiftUI
import WidgetKit

@main
struct CountdownVIWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
        CountdownLiveActivity()
    }
}
