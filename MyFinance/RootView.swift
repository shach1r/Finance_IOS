import SwiftUI

struct RootView: View {

    @EnvironmentObject var state: AppState
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeView()
                .tabItem { Label("Главная", systemImage: "house.fill") }
                .tag(0)

            TransactionsView()
                .tabItem { Label("Операции", systemImage: "list.bullet") }
                .tag(1)

            ReportView()
                .tabItem { Label("Отчёт", systemImage: "chart.pie.fill") }
                .tag(2)

            GoalsView()
                .tabItem { Label("Цели", systemImage: "target") }
                .tag(3)

            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
                .tag(4)
        }
    }
}
