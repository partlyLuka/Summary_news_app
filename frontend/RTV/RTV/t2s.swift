import SwiftUI
import AVFoundation

struct ArticleView: View {
    let title: String
    let author: String
    let content: String
    @State private var isFast: Bool = false
    @State private var isPlaying = false // State to track if speech is playing or paused
    @State private var utterance: AVSpeechUtterance? // State to store the current utterance
    private let synthesizer = AVSpeechSynthesizer()
    
    // Strong reference to the delegate to avoid deallocation
    @StateObject private var speechDelegate = SpeechDelegate()
    
    // Computed property for speech rate based on isFast toggle
    var speed: Float {
        return isFast ? 0.6 : 0.4 // Adjust these values if needed
    }
    
    // Function to create and return an AVSpeechUtterance
    private func createUtterance() -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: content)
        
        // Retrieve and use Siri's voice
        if let siriVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact") {
            utterance.voice = siriVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Fallback
        }
        
        // Set the speech rate (default to normal speed)
        utterance.rate = speed // Adjust the rate as needed
        
        return utterance
    }
    
    // Function to speak the article content
    private func speakText() {
        // Create a new utterance
        utterance = createUtterance()
        
        // Assign the delegate to handle the end of the speech
        synthesizer.delegate = speechDelegate
        speechDelegate.didFinishUtterance = {
            isPlaying = false // Reset to not playing when finished
        }
        
        // Speak the created utterance
        if let currentUtterance = utterance {
            synthesizer.speak(currentUtterance)
            isPlaying = true // Set playing state to true
        }
    }
    
    // Function to stop speech
    private func stopSpeech() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isPlaying = false // Set playing state to false
        utterance = nil // Reset utterance when stopped
    }
    
    // Function to reset the speech and ensure it starts from the beginning when replayed
    private func resetSpeech() {
        stopSpeech() // Stop any current speech
        utterance = nil // Reset the utterance to start from the beginning on next play
    }

    // Function to pause/resume speech
    private func togglePauseResume() {
        if synthesizer.isSpeaking && !synthesizer.isPaused {
            synthesizer.pauseSpeaking(at: .immediate)
            isPlaying = false
        } else if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true
        } else {
            speakText() // Start speech if not playing
        }
    }
    
    // Function to toggle speed and restart the speech
    private func toggleSpeed() {
        isFast.toggle() // Toggle the speed state
        
        // If speech is currently playing, stop and restart it with the new speed
        if isPlaying {
            stopSpeech()
            speakText() // Restart with the new speed
        }
    }

    var body: some View {
        VStack {
            // Content scrollable area
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title of the article
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    // Author information
                    Text("\(author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Content of the article
                    Text(content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            Spacer() // Ensure buttons are pushed to the bottom
            
            // Buttons in the bottom line
            HStack {
                // Reset button on the bottom left
                Button(action: {
                    resetSpeech() // Reset the speech when the button is pressed
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding(20)
                        
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                
                // Play/Pause button at the bottom center
                Button(action: {
                    togglePauseResume() // Play/Pause speech when the button is pressed
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        //.padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .center) // Align to the center
                
                // Speed button on the bottom right
                Button(action: {
                    toggleSpeed() // Call the toggle speed function
                }) {
                    Image(systemName: isFast ? "hare.fill" : "tortoise.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .trailing) // Align to the right
            }
            //.padding(.bottom) // Set padding to ensure it reaches the bottom edge
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // Ignore the safe area at the bottom to ensure buttons are flush with the edge
    }
}

// Delegate class to handle speech synthesis progress and completion
class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    var didFinishUtterance: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Call the completion closure when speech is finished
        didFinishUtterance?()
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(
            title: "Sample Article Title",
            author: "John Doe",
            content: "This is the content of the article. It will be spoken aloud when the button is pressed."
        )
    }
}

