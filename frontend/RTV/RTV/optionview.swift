import SwiftUI


let prevodi : [String : String] = ["kultura" : "culture", "slovenija" : "slovenia", "svet" : "world", "sport" : "sports", "zabava-in-slog" : "fun"]

// Modified _ContentView with a red back button
struct _ContentView: View {
    @Binding var currentView: String  // This binding allows going back to SelectionView
    @State var host: String
    @State var jsonData: [String: Any] = [:]
    @State var articles: [[String: String]] = []
    @State var isSlo: Bool = true

    var language: String {
        return isSlo ? "slo" : "eng"
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var back : String {
        if isSlo {"Nazaj"} else {"Back"}
    }
    

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(jsonData.keys.sorted(), id: \.self) { key in
                        var display_key : String {
                            if isSlo {key} else {prevodi[key] ?? "problem"}
                        }
                        NavigationLink(destination: MonthSelectionView(key: key, host: host, jsonData: jsonData[key] as! [String], language: language, isSlo: $isSlo)) {
                            ZStack {
                                Image(key) // Placeholder image, replace with your image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                
                                Text(display_key.capitalized(with: nil))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 150, height: 150)
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("RTV") // First layer title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSlo.toggle()
                    }) {
                        Text(language.capitalized(with: nil))
                    }
                }

                // Red Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentView = "Selection"  // Go back to selection
                    }) {
                        Text(back)
                            .padding()
                            .foregroundColor(.red)
                            .cornerRadius(8)
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

    func fetchData() async {
        let url = host_generateURL_menu(host: host) // Example URL
        do {
            let jsonString = try await send_get(url: url!)
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

struct MonthSelectionView: View {
    var key: String
    var host: String
    var jsonData: [String]
    var language: String
    @Binding var isSlo: Bool
    @State private var selectedMonth: String? = nil  // Track the selected month
    var display_key : String {
        if language == "slo" {key} else {
            prevodi[key] ?? "error"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sortedMonths, id: \.self) { month in
                    
                    VStack(alignment: .leading) {
                        Button(action: {
                            withAnimation {
                                selectedMonth = selectedMonth == month ? nil : month
                            }
                        }) {
                            Text(month)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .padding(.horizontal)
                        }

                        if selectedMonth == month {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(groupedByMonth[month] ?? [], id: \.self) { date in
                                    let url = host_generateURL_retrieve(host: host, rubric: key, date: date, language: language)
                                    let fdate = formatDate(date: date) ?? "fail"
                                    NavigationLink(destination: ArticlesView(url: url!, date: fdate, isSlo: isSlo)) {
                                        Text(fdate)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(display_key.capitalized(with: nil)) // Second layer title
    }

    var groupedByMonth: [String: [String]] {
        var result = [String: [String]]()
        for date in jsonData {
            let month = monthName(for: date)
            result[month, default: []].append(date)
        }
        return result
    }

    var sortedMonths: [String] {
        groupedByMonth.keys.sorted {
            guard let date1 = monthToDate($0), let date2 = monthToDate($1) else { return false }
            return date1 > date2
        }
    }

    func monthName(for date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // This matches the format of your dates
        if let dateObject = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "MMMM yyyy"  // Display full month name and year
            return dateFormatter.string(from: dateObject)
        }
        return "Unknown Month"
    }

    func monthToDate(_ month: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"  // Match the format of the month keys
        return dateFormatter.date(from: month)
    }
}



// Modified _SummaryView with a red back button
struct _SummaryView: View {
    @Binding var currentView: String  // This binding allows going back to SelectionView
    @State var host: String
    @State var jsonData: [String: Any] = [:]
    @State var isSlo: Bool = true
    
    var summary_option: [String] = ["This_week", "Past_week"]
    
    var language: String {
        return isSlo ? "slo" : "eng"
    }
    
    // Define columns for the grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var summary : String {
        if isSlo {"Povzetek"} else {"Summary"}
    }
    var back : String {
        if isSlo {"Nazaj"} else {"Back"}
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(jsonData.keys.sorted(), id: \.self) { rubric in
                        var display_rubric : String {
                            if isSlo {rubric} else {prevodi[rubric] ?? "error"}
                        }
                        NavigationLink(destination:
                                        SummaryOptionView(summary_option: summary_option, rubric: rubric, language: language, host: host)) {
                            ZStack {
                                Image(rubric) // Placeholder image, replace with your image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                
                                Text(display_rubric.capitalized(with: nil))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 150, height: 150)
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(summary)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSlo.toggle()
                    }) {
                        Text(language.capitalized(with: nil))
                    }
                }
                
                // Red Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentView = "Selection"  // Go back to selection
                    }) {
                        Text(back)
                            .padding()
                            .foregroundColor(.red)
                            .cornerRadius(8)
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

    func fetchData() async {
        let url = host_generateURL_menu(host: host)! // Example URL
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

// Redesigned SelectionView with a more professional layout and appearance
// Redesigned SelectionView with a more professional layout and appearance
struct SelectionView: View {
    @State var host: String = "localhost:8080"  // Allow user input for the host
    @State private var currentView: String = "Selection"  // Track the current view
    @State private var translation: CGFloat = 0.0  // Track swipe gesture translation
    @State private var offsetX: CGFloat = 0.0  // Offset for the transition effect
    
    var body: some View {
        ZStack {
            // Main Content View (Summary or Content)
            if currentView == "Content" {
                _ContentView(currentView: $currentView, host: host)
                    .transition(.move(edge: .trailing))
                    .offset(x: offsetX)
            } else if currentView == "Summary" {
                _SummaryView(currentView: $currentView, host: host)
                    .transition(.move(edge: .leading))
                    .offset(x: offsetX)
            } else {
                VStack {
                    Text("Choose how to digest news")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)
                    
                    Text("Swipe right to generate your own news summaries")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Text("Swipe left to read the standard news")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    // TextField for host input
                    TextField("Enter host address", text: $host)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Spacer()

                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .padding()

                        Text("Read & listen to the news")
                            .font(.headline)
                            .padding()

                        Spacer()
                        
                        Text("Create your own news")
                            .font(.headline)
                            .padding()

                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .padding()
                    }
                    .padding(.bottom, 40)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(
//                    LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
//                )
                .transition(.identity)
                .offset(x: offsetX)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    translation = value.translation.width
                    offsetX = translation
                }
                .onEnded { value in
                    withAnimation(.easeInOut) {
                        if translation > 100 {  // Swipe right
                            currentView = "Content"
                            offsetX = UIScreen.main.bounds.width
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                offsetX = 0
                            }
                        } else if translation < -100 {  // Swipe left
                            currentView = "Summary"
                            offsetX = -UIScreen.main.bounds.width
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                offsetX = 0
                            }
                        } else {
                            offsetX = 0
                        }
                    }
                    translation = 0  // Reset translation after swipe
                }
        )
        .animation(.easeInOut, value: currentView)
    }
}



// Main entry point view to show SelectionView
struct MainView: View {
    var body: some View {
        SelectionView()
    }
}

// Preview for MainView
struct MaMinView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            
    }
}

