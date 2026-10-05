import SwiftUI

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .installToast(position: .bottom)
        .toastStyle(ToastStyle(cornerRadius: 16, shadow: .init(color: .black.opacity(0.2), radius: 12, y: 6)))
    }
  }
}
