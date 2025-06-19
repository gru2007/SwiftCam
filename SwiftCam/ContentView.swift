import SwiftUI

/// Корневой экран приложения. Сразу отображает камеру
struct ContentView: View {
    var body: some View {
        ManualCameraView()
    }
}

#Preview {
    ContentView()
}
