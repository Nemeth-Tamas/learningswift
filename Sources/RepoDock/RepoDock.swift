import SwiftUI

@main
struct RepoDockApp: App {
    var body: some Scene {
        WindowGroup("RepoDock") {
            ContentView()
        }
        .defaultSize(width: 720, height: 480)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))

            Text("RepoDock")
                .font(.largeTitle.bold())

            Text("Native macOS SwiftUI is alive.")
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 560, minHeight: 360)
        .padding()
    }
}
