import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedText: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first,
                  let document = PDFDocument(url: url) else {
                parent.selectedText = "Failed to read PDF."
                return
            }

            var fullText = ""
            for pageIndex in 0..<document.pageCount {
                if let page = document.page(at: pageIndex),
                   let text = page.string {
                    fullText += text + "\n"
                }
            }

            parent.selectedText = fullText.isEmpty ? "No text found in PDF." : fullText
        }
    }
}
