import SwiftUI

@main
struct CountdownVIApp: App {
    var body: some Scene {
        WindowGroup {
            CountdownView()
                .preferredColorScheme(.dark)
        }
    }
}
