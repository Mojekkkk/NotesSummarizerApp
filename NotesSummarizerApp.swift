import SwiftUI

@main
struct NotesSummarizerApp: App {
    @StateObject private var historyManager = HistoryManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .environmentObject(historyManager) 
                    .tabItem { Label("Home", systemImage: "house") }

                HistoryView()
                    .environmentObject(historyManager)
                    .tabItem { Label("History", systemImage: "clock") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}
