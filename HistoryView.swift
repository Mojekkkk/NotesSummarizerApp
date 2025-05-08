import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @State private var searchText: String = ""

    var filteredHistory: [SummaryEntry] {
        if searchText.isEmpty {
            return historyManager.history
        } else {
            return historyManager.history.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("History")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 20)

                Text("Total time saved: \(historyManager.totalTimeSaved) min")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                HStack {
                    TextField("Search summaries...", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top)

                List {
                    ForEach(filteredHistory) { entry in
                        NavigationLink(
                            destination: SummarizeOptionsView(
                                originalText: entry.fullText,
                                summaryPercent: 30,
                                isFromHistory: true
                            )
                            .environmentObject(historyManager) 
                        ) {
                            HStack(alignment: .top, spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(entry.preview.prefix(1))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(entry.preview)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}
