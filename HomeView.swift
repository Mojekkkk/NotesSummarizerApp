import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import Vision

struct HomeView: View {
    @State private var noteText: String = ""
    @State private var showSummarizeOptions = false
    @State private var summaryPercent: Int = 10

    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showDocumentPicker = false
    @State private var showVoiceInput = false

    @State private var selectedImage: UIImage?
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Summarizer")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                HStack(spacing: 30) {
                    Button {
                        showCamera = true
                    } label: {
                        VStack {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Camera").font(.caption)
                        }
                    }

                    Button {
                        showGallery = true
                    } label: {
                        VStack {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Gallery").font(.caption)
                        }
                    }

                    Button {
                        showDocumentPicker = true
                    } label: {
                        VStack {
                            Image(systemName: "doc.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Files").font(.caption)
                        }
                    }

                    Button {
                        showVoiceInput = true
                    } label: {
                        VStack {
                            Image(systemName: "mic.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Voice").font(.caption)
                        }
                    }
                }

                ZStack(alignment: .topTrailing) {
                    TextEditor(text: $noteText)
                        .frame(height: 200)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($isTextEditorFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isTextEditorFocused = false
                                }
                            }
                        }

                    HStack(spacing: 10) {
                        if noteText.isEmpty {
                            Button(action: {
                                if let pasteboard = UIPasteboard.general.string {
                                    noteText = pasteboard
                                }
                            }) {
                                Image(systemName: "document.on.document")
                                    .padding(8)
                            }
                            .foregroundStyle(.black)
                            
                        } else {
                            Button(action: {
                                noteText = ""
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(8)
                            }
                        }
                    }
                    .padding(.trailing, 8)
                }

                VStack {
                    Text("Summary Length: \(summaryPercent)%")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Slider(value: Binding(
                        get: { Double(summaryPercent) },
                        set: { summaryPercent = Int($0) }
                    ), in: 1...100, step: 1)
                        .accentColor(.purple)
                        .padding(.horizontal)
                        .frame(height: 30)
                }

                Button(action: {
                    if !noteText.isEmpty {
                        showSummarizeOptions = true
                    }
                }) {
                    Text("Summary")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(noteText.isEmpty ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .disabled(noteText.isEmpty)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showSummarizeOptions) {
                SummarizeOptionsView(originalText: noteText, summaryPercent: summaryPercent)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera, image: $selectedImage)
            }
            .sheet(isPresented: $showGallery) {
                ImagePicker(sourceType: .photoLibrary, image: $selectedImage)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedText: $noteText)
            }
            .sheet(isPresented: $showVoiceInput) {
                VoiceInputView(transcribedText: $noteText)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onTapGesture {
                isTextEditorFocused = false
            }
            .onChange(of: selectedImage) { _, newImage in
                if let newImage = newImage {
                    recognizeText(from: newImage)
                }
            }
        }
    }

    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            noteText = "Failed to process image."
            return
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                DispatchQueue.main.async {
                    self.noteText = text.isEmpty ? "No text found in image." : text
                }
            } else {
                DispatchQueue.main.async {
                    self.noteText = "Failed to extract text."
                }
            }
        }

        request.recognitionLevel = .accurate

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.noteText = "OCR failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
