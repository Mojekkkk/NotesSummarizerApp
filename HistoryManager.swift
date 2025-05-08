import Foundation

struct SummaryEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let preview: String
    let fullText: String
    let date: Date

    init(title: String, preview: String, fullText: String) {
        self.id = UUID()
        self.title = title
        self.preview = preview
        self.fullText = fullText
        self.date = Date()
    }
}

class HistoryManager: ObservableObject {
    @Published var summaries: [SummaryEntry] = []

    var history: [SummaryEntry] {
        return summaries
    }

    var totalTimeSaved: Int {
        return summaries.count * 3
    }

    private let saveKey = "SavedSummaries"

    init() {
        loadSummaries()
    }

    func addSummary(title: String, preview: String, fullText: String) {
        let entry = SummaryEntry(title: title, preview: preview, fullText: fullText)
        summaries.insert(entry, at: 0)
        saveSummaries()
    }

    func deleteSummary(at offsets: IndexSet) {
        summaries.remove(atOffsets: offsets)
        saveSummaries()
    }

    func loadSummaries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([SummaryEntry].self, from: data) {
            self.summaries = decoded
        }
    }

    func saveSummaries() {
        if let encoded = try? JSONEncoder().encode(summaries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
