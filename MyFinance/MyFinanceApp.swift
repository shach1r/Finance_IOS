import SwiftUI

@main
struct MyFinanceApp: App {

    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(colorScheme(for: state.settings.theme))
        }
    }

    private func colorScheme(for theme: ThemeChoice) -> ColorScheme? {
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
