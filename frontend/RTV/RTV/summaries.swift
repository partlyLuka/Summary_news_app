import SwiftUI
import Foundation


import AVFoundation

struct UUIDWrapper: Identifiable {
    var id: String
}

struct SummaryContentView: View {
    let title: String
    let author: String
    let content: String
    let host : String
    let language : String
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
                TextView(host:host, language : language, title : title, author : author, content : content)
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


func generateURL_summary(rubric:String, sum_type:String, week_number:String, language:String) -> String? {
    var components = URLComponents()
    components.scheme = "http"
    components.host = "localhost"
    components.port = 8080
    components.path = "/summary"
    
    // Add query items
    components.queryItems = [
        URLQueryItem(name: "rubric", value: rubric),
        URLQueryItem(name: "sum_type", value: sum_type),
        URLQueryItem(name: "week_number", value: week_number),
        URLQueryItem(name: "language", value: language)
    ]
    
    // Return the final URL string
    return components.url?.absoluteString
}

let option_prevodi : [String : String] = ["This_week" : "Ta_teden", "Past_week" : "Prejšnji teden"]

struct SummaryOptionView: View {
    
    let summary_option: [String]
    let rubric: String
    let language: String
    let host: String
    var display_sum_options : String {
        if language == "eng" {"Options"} else {"Možnosti"}
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {  // Add spacing between options
                    ForEach(0..<summary_option.count, id: \.self) { i in
                        let sum_type = summary_option[i]
                        var display_sum_type : String {
                            if language=="eng" {sum_type} else {option_prevodi[sum_type] ?? "error"}
                        }
                        let url = host_generateURL_summary(host: host, rubric: rubric, sum_type: sum_type, week_number: "0", language: language)
                        
                        NavigationLink(destination: DisplaySummary(url: url!, host : host, language : language)) {
                            Text(display_sum_type.replacingOccurrences(of: "_", with: " "))
                                .font(.headline)  // Make the text bold
                                .multilineTextAlignment(.center)  // Center the text
                                .frame(maxWidth: .infinity)  // Ensure the text takes up the full width
                                .padding()  // Add padding for better spacing
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.blue, lineWidth: 2)  // Add a rounded border
                                )
                                .padding(.horizontal)  // Add horizontal padding to separate from the edges
                        }
                    }
                }
                .padding()  // Add some padding around the VStack
            }
            .navigationTitle(display_sum_options)
        }
    }
}


struct DisplaySummaryContent: View {
    let content: String
    let host : String
    let language : String
    
    var display_generating : String {
        if language == "eng" {"Generating..."} else {"Ustvarjam..."}
    }
    var body: some View {
        if content == "Generating" {
            VStack {
                Spacer()
                
                // "Generating" text in the middle of the screen
                Text(display_generating)
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Loading spinner under the "Generating" text
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)  // Scale to make the spinner larger
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            SummaryContentView(title: "Summary", author: "Summary", content: content, host : host, language : language)
        }
    }
}


struct DisplaySummary: View {
    let url: String
    let host : String
    let language : String
    var display_generate : String {
        if language == "eng" {"Generate"} else {"Ustvari"}
    }
    
    @State var content: String = "Generating"
    @State private var showContent: Bool = false  // Track whether to show content
    
    var body: some View {
        VStack {
            Spacer()  // Add a spacer to push the button/content to the bottom
            
            if showContent {
                DisplaySummaryContent(content: content, host : host, language : language)
                    .onAppear {
                        Task {
                            await fetch()
                        }
                    }
            } else {
                Button(action: {
                    showContent = true  // Show the content when the button is pressed
                }) {
                    Text(display_generate)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)  // Set the background color to white
    }
    
    func fetch() async {
        do {
            content = try await send_get(url: url)
        } catch {
            print("Error fetching content")
        }
    }
}

struct SummaryView: View {
    @State var jsonData: [String: Any] = [:]
    @State var isSlo: Bool = false
    @State var host : String = "localhost:8080"
    var summary_option: [String] = ["This_week", "Past_week"]
    
    var language: String {
        return isSlo ? "slo" : "eng"
    }
    
    var body: some View {
        NavigationStack {
            List(jsonData.keys.sorted(), id: \.self) { rubric in
                NavigationLink(destination:
                                SummaryOptionView(summary_option: summary_option, rubric : rubric, language : language, host : host)) {
                    Text(rubric.capitalized(with: nil))
                }
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSlo.toggle()
                    }) {
                        Text(language.capitalized(with: nil))
                    }
                }
            }
            .onAppear {
                Task {
                    await fetchData()
                }
            }
        }
    }

    // Fetch data from the URL, convert to JSON, and extract the dictionary
    func fetchData() async {
        let url = host_generateURL_menu(host : host)! // Example URL
        do {
            let jsonString = try await send_get(url: url)
            if let json = convertToJSON(from: jsonString) as? [String: Any] {
                jsonData = json // Store the entire JSON dictionary
            } else {
                print("Error: JSON is not a dictionary")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}


struct Sheet: View {
    let title: String
    let author: String
    let content: String
    let time: String
    let date: String // Added the date variable

    // Computed property to format the date string
    private var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long // Displays date in "Month Day, Year" format

        if let date = inputFormatter.date(from: date) {
            return outputFormatter.string(from: date)
        } else {
            return date // Return the original string if parsing fails
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(author)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(time.replacingOccurrences(of: ".", with: ":"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Content
                    Text(content)
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("") // Hide default title space
        }
    }
}


struct SheetView : View {
    @State var url : String
    @State var language : String
    @State var title = ""
    @State var author = ""
    @State var content = ""
    @State var time = ""
    @State var date = ""
    var body : some View {
        Sheet(title : title, author : author, content : content, time : time, date: date)
            .onAppear {
                Task {
                    await fetch()
                }
            }
    }
    func fetch() async {
        do {
            let st = try await send_get(url : url)
            if let article = convertToJSONStringDictionary(from: st) {
                var content_key : String {
                    if language == "slo" {"content"} else {"english_content"}
                }
                var title_key : String {
                    if language == "slo" {"title"} else {"english_title"}
                }
                var author_key : String = "author"
                
                title = article[title_key] ?? "No title"
                content = article[content_key] ?? "No content"
                author = article[author_key] ?? "No author"
                time = article["time"] ?? "No time"
                date = article["date"] ?? "2000-01-1"
            } else {title = "Error"}
        } catch {
            title = "Error"}
        
    }
}



import UIKit




struct TextView: View {
    @State var host: String = "localhost:8080"
    @State var language: String = "eng"
    @State var title: String
    @State var author: String
    @State var content: String
    @State private var selectedUUID: String? = nil
    @State private var showHiView: Bool = false
    var display_title : String {
        if language=="slo" {"Povzetek"} else {"Summary"}
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title of the article
                Text(display_title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                
                // Content of the article
                AttributedTextView(attributedText: attributedString(from: content)) { code in
                    self.selectedUUID = code
                    self.showHiView = true
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .sheet(isPresented: $showHiView) {
            // Sheet content with a close button
            NavigationView {
                let url = host_generateURL_get(host: host, uuid: selectedUUID ?? "")!
                SheetView(url: url, language: language)
                    .font(.largeTitle)
                    .padding()
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                self.showHiView = false
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                        }
                    }
            }
        }
    }

    func attributedString(from content: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let pattern = ">(.*?)<"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        var lastLocation = 0

        for match in matches {
            let codeRange = match.range(at: 1)
            let fullRange = match.range(at: 0)

            // Append text before this match
            if fullRange.location > lastLocation {
                let range = NSRange(location: lastLocation, length: fullRange.location - lastLocation)
                let text = nsString.substring(with: range)
                let attrText = NSAttributedString(string: text)
                attributedString.append(attrText)
            }

            // Extract the UUID
            let code = nsString.substring(with: codeRange)

            // Create an image attachment with the SF Symbol
            let attachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
            if let image = UIImage(systemName: "arrow.up.circle", withConfiguration: config)?.withTintColor(.blue) {
                attachment.image = image
            }

            // Create an attributed string with the attachment
            let attachmentString = NSAttributedString(attachment: attachment)

            // Create a mutable copy to add link attributes
            let linkAttrString = NSMutableAttributedString(attributedString: attachmentString)

            // Add link attribute
            linkAttrString.addAttribute(.link, value: code, range: NSRange(location: 0, length: linkAttrString.length))

            // Adjust baseline to align the image properly with text
            linkAttrString.addAttribute(.baselineOffset, value: -3, range: NSRange(location: 0, length: linkAttrString.length))

            // Append the attributed string with the image and link
            attributedString.append(linkAttrString)

            // Update lastLocation
            lastLocation = fullRange.location + fullRange.length
        }

        // Append any remaining text after the last match
        if lastLocation < nsString.length {
            let range = NSRange(location: lastLocation, length: nsString.length - lastLocation)
            let text = nsString.substring(with: range)
            let attrText = NSAttributedString(string: text)
            attributedString.append(attrText)
        }

        // Set the font for the entire string
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}

struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    let onLinkTapped: (String) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.dataDetectorTypes = []
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onLinkTapped: onLinkTapped)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let onLinkTapped: (String) -> Void

        init(onLinkTapped: @escaping (String) -> Void) {
            self.onLinkTapped = onLinkTapped
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            onLinkTapped(URL.absoluteString)
            return false // Prevent default action
        }
    }
}





struct p: PreviewProvider {
    static var options = ["This week"]
    static var cc: String = """
Summary : Slovenia's energy self-sufficiency is a key question after the closure of Tessa, with experts suggesting a hydroelectric plant on the upper Sava and second block of nuclear power plants. A floating solar power plant on Lake Djurmyr is also proposed, offering opportunities for research and tourism.
 
>ed1005ea-a407-4c40-af51-4458c2475d8c<
 
Summary : Pregnant women in Slovenia will receive free vaccinations against respiratory syncytial virus (RSV) from next week to protect newborns from the disease, which is a common cause of hospitalization in young children.
 
>4746cf9f-7f48-4672-9764-8fdc5d07eab6<
 
Summary : The Court of Auditors found that the Slovenian Democratic Party (SD) received a â‚¬2900 contribution from foreign nationals, which is prohibited by law. However, the party claimed the money was for humanitarian purposes and took corrective action, which was deemed satisfactory.
 
>84055dec-2564-42ee-a80b-8b6e0904b238<
 
Summary : The Slovenian Parliament (DZ) will hold its September meeting, featuring Minister of Digital Transformation Emilia StÃ¶menova Spirit speaking to MEPs about the purchase of 13,000 computers, which was criticized by the Court of Auditors. The meeting will also consider several legislative proposals, including a new aviation law, government novel law on local elections, and draft laws on protecting public order and peace, companies, and Roma issues.
 
>eb2ca9f3-97ef-497e-b3a2-a05536842aa4<
 
Summary : European Commissioner Romano Tomc criticized Slovenian candidate Marta Kos for allegedly cooperating with the Yugoslav secret service Udbo, which Kos denies. Tomc also questioned Kos' leadership experience and residency outside the EU. Kos responded by denying all allegations and highlighting her past roles as Government Communications Office Director and Government Press Secretary.
 
>11046154-53b6-4ecb-aedb-542ad9d5f636<
 
Summary : Slovenia is participating in European Mobility Week, encouraging people to change their attitude towards cars and promoting sustainable transportation. The country will close streets and parking lots in over a third of its municipalities to prioritize walking, cycling, and public transportation. The event will include car-free days, bicycle breakfasts, and workshops to educate citizens about alternative transportation options.
 
>53de0805-e0d8-4f33-8bf6-197821bc8131<
"""
    static var previews: some View {
        TextView(title: "Title", author: "Me", content: cc)
    }
}

