import Foundation
import AVFoundation
import Speech

class VoiceInputViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0

    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var accumulatedText: String = ""
    private var onResultCallback: ((String) -> Void)?
    private var timer: Timer?

    func toggleRecording(onResult: @escaping (String) -> Void) {
        onResultCallback = onResult
        isRecording ? stopRecording() : startRecording()
    }

    func startRecording() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }

            DispatchQueue.main.async {
                self.isRecording = true
                self.accumulatedText = ""
                self.elapsedTime = 0
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.elapsedTime += 1
                }
            }

            self.request = SFSpeechAudioBufferRecognitionRequest()
            guard let request = self.request else { return }

            let node = self.audioEngine.inputNode
            let format = node.outputFormat(forBus: 0)

            node.removeTap(onBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            do {
                try self.audioEngine.start()
            } catch {
                print("AudioEngine error: \(error.localizedDescription)")
                return
            }

            self.recognitionTask = self.recognizer?.recognitionTask(with: request) { result, _ in
                if let result = result {
                    let spokenText = result.bestTranscription.formattedString
                    self.accumulatedText = spokenText
                    DispatchQueue.main.async {
                        self.onResultCallback?(spokenText)
                    }
                }
            }
        }
    }


    
    func stopRecording() {
        print("Stopping recording...")
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        if let task = recognitionTask, task.isCancelled {
            print("Recognition task is already been stopped")
        } else {
            print("Recognition task has not cancelled.")
        }


        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if audioEngine.isRunning {
            print("Audio Engine is still running.")
        }

        request?.endAudio()
        request = nil
        
        if request == nil {
            print("request == nil")
        }

        timer?.invalidate()
        timer = nil

        DispatchQueue.main.async {
            self.isRecording = false
            self.onResultCallback?(self.accumulatedText) // Return accumulated text
        }
    }
}
