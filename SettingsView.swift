import SwiftUI
import MessageUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("showTips") private var showTips = true
    @State private var selectedLanguage = "English"
    
    let languages = ["English", "Spanish", "Turkish"]
    @State private var showMail = false
    @State private var showTipsPopup = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .onChange(of: isDarkMode) { _, newValue in
                        getWindows().first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                    }
                    
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    Toggle(isOn: $showTips) {
                        Label("Show Tips", systemImage: "lightbulb.fill")
                    }
                    .onChange(of: showTips) { _, value in
                        if value {
                            showTipsPopup = true
                        }
                    }
                    
                    Picker(selection: $selectedLanguage, label: Label("Language", systemImage: "globe")) {
                        ForEach(languages, id: \.self) { lang in
                            Text(lang)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        openEmail()
                    }) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }
                    
                    Button(action: {
                        rateApp()
                    }) {
                        Label("Rate This App", systemImage: "star.fill")
                    }
                    
                    Button(action: {
                    }) {
                        Label("FAQ", systemImage: "questionmark.circle.fill")
                    }
                }
                .foregroundStyle(.black)
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showTipsPopup) {
                Alert(
                    title: Text("Tips Enabled!"),
                    message: Text("You will now receive useful tips during your app usage."),
                    dismissButton: .default(Text("Got it!"))
                )
            }
        }
    }
    
    func openEmail() {
        if let emailUrl = URL(string: "mailto:tashayev@gmail.com") {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/id0000000") {
            UIApplication.shared.open(url)
        }
    }
}
