import SwiftUI
import Speech

struct VoiceInputView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transcribedText: String
    @StateObject private var viewModel = VoiceInputViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Tap the mic to start/stop recording")
                .font(.headline)

            Text("Recording Time: \(formatTime(viewModel.elapsedTime))")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: {
                viewModel.toggleRecording { result in
                    
                    print("Result transcribedText", transcribedText)
                    
                    transcribedText = result.isEmpty ? "Empty" : result
                }
            }) {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(viewModel.isRecording ? .red : .blue)
            }

            Spacer()
        }
        .padding()

    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let intSec = Int(seconds)
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
