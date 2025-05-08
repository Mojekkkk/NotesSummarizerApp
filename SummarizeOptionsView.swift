import SwiftUI
import PDFKit

struct SummarizeOptionsView: View {
    let originalText: String
    let summaryPercent: Int
    var isFromHistory: Bool = false

    @EnvironmentObject var historyManager: HistoryManager
    @State private var summaries: [String: String] = [:]
    @State private var isLoading: Bool = false
    @State private var expandedType: String? = nil
    @State private var showingEditor = false
    @State private var editableText: String = ""

    let options: [(type: String, description: String)] = [
        ("Extract", "Only essential sentences."),
        ("Highlighted", "Marks key parts of the text."),
        ("Bullet Points", "Key ideas at a glance."),
        ("Abstract", "Advanced AI Summarization."),
        ("Paraphrase", "Rewrites the text simply."),
        ("Rewrite", "Changes tone: friendly, formal, fun.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(options, id: \.type) { option in
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            toggleExpansion(for: option.type)
                        }) {
                            HStack {
                                Image(systemName: expandedType == option.type ? "chevron.up" : "chevron.down")
                                VStack(alignment: .leading) {
                                    Text(option.type)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text(option.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        if expandedType == option.type {
                            if isLoading {
                                ProgressView().padding()
                            } else if let result = summaries[option.type] {
                                HStack(spacing: 25) {
                                    Button(action: {
                                        editableText = result
                                        showingEditor = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    Button(action: {
                                        exportToPDF(summary: result, type: option.type)
                                    }) {
                                        Image(systemName: "doc.richtext")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    Button(action: {
                                        shareText(result)
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    Button(action: {
                                        UIPasteboard.general.string = result
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal)

                                Text(result)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingEditor) {
            NavigationView {
                ScrollView {
                    TextEditor(text: $editableText)
                        .padding()
                        .frame(minHeight: 300)
                }
                .navigationTitle("Edit Summary")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            if let type = expandedType {
                                summaries[type] = editableText
                            }
                            showingEditor = false
                        }
                    }
                }
            }
        }
    }

    private func toggleExpansion(for type: String) {
        if expandedType == type {
            expandedType = nil
        } else {
            expandedType = type
            if summaries[type] == nil {
                generateSummary(for: type)
            }
        }
    }

    private func generateSummary(for type: String) {
        isLoading = true
        OpenAIService.shared.summarize(text: originalText, type: type, percent: summaryPercent) { result in
            DispatchQueue.main.async {
                self.summaries[type] = result
                self.isLoading = false
                if !isFromHistory {
                    saveToHistory(summary: result)
                }
            }
        }
    }

    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        getWindows().first?.rootViewController?.present(activityVC, animated: true)
    }

    private func exportToPDF(summary: String, type: String) {
        let pdfMetaData = [
            kCGPDFContextCreator: "TextSummary",
            kCGPDFContextAuthor: "Your App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
            summary.draw(in: CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40), withAttributes: attributes)
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(type)-Summary.pdf")
        try? data.write(to: tempURL)
        shareText(tempURL)
    }

    private func shareText(_ url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        getWindows().first?.rootViewController?.present(vc, animated: true)
    }

    private func saveToHistory(summary: String) {
        let title = String(originalText.prefix(30))
        let preview = String(summary.prefix(60))
        historyManager.addSummary(title: title, preview: preview, fullText: originalText)
    }
}
