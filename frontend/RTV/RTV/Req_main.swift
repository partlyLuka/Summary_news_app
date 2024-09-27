import SwiftUI
import Foundation

import Foundation

// Function to convert a JSON string to a list of dictionaries
import Foundation



func formatDate(date : String) -> String {
    let data = date.split(separator : "-")
    if (data.count) != 3 {
        return "fail"
    } else {
        let month = Int(data[1])
        let day = Int(data[2])
        if let month = month, let day = day {
            return "\(day). \(month)."
        }
        else {return "\(day). \(month)."}
    }
}



// Function to convert a JSON string to a list of dictionaries
func convertStringToListOfDictionaries(jsonString: String) -> [[String: Any]]? {
    // Ensure the JSON string is valid UTF-8 encoded data
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Invalid JSON string")
        return nil
    }
    
    do {
        // Use JSONSerialization to convert the data into a list of dictionaries
        if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
            return jsonArray
        } else {
            print("Error: JSON is not in expected format")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}


func generateURL(rubric: String, date: String, language: String) -> String? {
    var components = URLComponents()
    components.scheme = "http"
    components.host = "localhost"
    components.port = 8080
    components.path = "/retrieve"
    
    // Add query items
    components.queryItems = [
        URLQueryItem(name: "rubric", value: rubric),
        URLQueryItem(name: "date", value: date),
        URLQueryItem(name: "top", value: "-1"),
        URLQueryItem(name: "language", value: language)
    ]
    
    // Return the final URL string
    return components.url?.absoluteString
}





// Function to send GET request and return the response as a string
func send_get(url: String) async throws -> String {
    guard let url = URL(string: url) else {
        throw URLError(.badURL)
    }
    
    // Create a custom configuration with no timeout
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 0      // No timeout for the request
    configuration.timeoutIntervalForResource = 0     // No timeout for the entire resource load
    
    // Create a custom URLSession with the configuration
    let session = URLSession(configuration: configuration)
    
    // Use the custom session to make the request
    let (data, response) = try await session.data(from: url)
    
    // Handle the response
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        if let resultString = String(data: data, encoding: .utf8) {
            return resultString
        } else {
            throw URLError(.cannotDecodeContentData)
        }
    } else {
        throw URLError(.badServerResponse)
    }
}

// Function to convert a string to a JSON object
func convertToJSON(from jsonString: String) -> Any? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Unable to convert string to data")
        return nil
    }
    
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        return jsonObject
    } catch {
        print("Error: Failed to convert string to JSON - \(error.localizedDescription)")
        return nil
    }
}

// SwiftUI View for displaying keys of the JSON

struct ContentView: View {
    @State var jsonData: [String: Any] = [:]
    @State var articles: [[String: String]] = []
    @State var isSlo: Bool = true
    @State var host : String = "7ca5a3b1cc123a.lhr.life"
    var language: String {
        return isSlo ? "slo" : "eng"
    }
    @State var url : String = "unassigned"
    
    var body: some View {
            
            
            NavigationStack {
                //Text(url)
                List(jsonData.keys.sorted(), id: \.self) { key in
                    NavigationLink(destination: (
                        List((jsonData[key] as! [String]).sorted(by: >), id: \.self) { date in
                            let url = host_generateURL_retrieve(host : host, rubric: key, date: date, language: language)
                            let fdate = formatDate(date: date) as String ?? "fail"
                            NavigationLink(destination: ArticlesView(url: url!, date: fdate, isSlo: isSlo)) {
                                Text(fdate)
                                //Text(url!)
                            }
                        }
                        .navigationTitle(key.capitalized(with: nil)) // Second layer title
                    )) {
                        Text(key.capitalized(with: nil))
                    }
                }
                .navigationTitle("RTV News") // First layer title
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { // Position on the right
                        Button(action : {
                            isSlo.toggle()
                        }) {
                            Text(language.capitalized(with : nil))
                                
                        }
                    }
                }
                .onAppear {
                    Task {
                        await fetchData()
                    }
                }
            }
             // Adjust padding to create the desired overlap effect
        
    }

    // Fetch data from the URL, convert to JSON, and extract the dictionary
    func fetchData() async {
        url = //"https://" + host + "/menu"
        host_generateURL_menu(host : host)!
        //"https://3cc317c4d880f4.lhr.life/menu"; // Example URL
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

// View for displaying details of the clicked key's value


struct ArticlesView: View {
    let url: String
    let date: String
    let isSlo: Bool
    
    @State var articles: [[String: Any]] = [["title": "title"], ["time": "time"], ["content": "content"], ["english_content": "english_content"], ["author": "author"]]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {  // Add spacing between titles
                    ForEach(0..<articles.count, id: \.self) { i in
                        let art = articles[i]
                        let author = art["author"] as? String ?? "unknown"
                        let time = (art["time"] as? String ?? "1.0").replacingOccurrences(of: ".", with: ":")
                        var content_key: String {
                            return isSlo ? "content" : "english_content"
                        }
                        var title_key: String {
                            return isSlo ? "title" : "english_title"
                        }
                        let content: String = art[content_key] as? String ?? "failed"
                        let title: String = art[title_key] as? String ?? "failed to convert"
                        
                        NavigationLink(destination:
                            VStack {
                                ArticleView(title: title, author: author, content: content)
                            }
                        ) {
                            VStack {
                                HStack {
                                    Text(title)
                                        .font(.headline)  // Make the text bold
                                        .multilineTextAlignment(.leading)  // Align the text to the left
                                    
                                    Spacer()  // Push the time text to the right
                                    
                                    Text(time)
                                        .font(.subheadline)  // Use a smaller font for time
                                        .foregroundColor(.black)
                                }
                                .padding()  // Add padding for better spacing
                                .frame(maxWidth: .infinity)  // Ensure the HStack takes up the full width
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.blue, lineWidth: 2)  // Add a rounded border
                                )
                                .padding(.horizontal)  // Add horizontal padding to separate from the edges
                                
                                Text("\(author)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                            }
                        }
                    }
                }
                .padding()  // Add some padding around the VStack
            }
            .navigationTitle(date)
            .onAppear {
                Task {
                    await fetch()
                }
            }
        }
    }
    
    func fetch() async {
        do {
            let st = try await send_get(url: url)
            if let lst = convertStringToListOfDictionaries(jsonString: st) {
                articles = lst
            } else {
                print("Failed to convert JSON string to list of dictionaries")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}

//struct ArticleView: View {
//    let title: String
//    let author: String
//    let content: String
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                // Title of the article
//                Text(title)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(.leading)
//                    .padding(.bottom, 8)
//
//                // Author information
//                Text("By \(author)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .padding(.bottom, 8)
//
//                // Content of the article
//                Text(content)
//                    .font(.body)
//                    .foregroundColor(.primary)
//                    .lineSpacing(6)
//                    .multilineTextAlignment(.leading)
//            }
//            .padding()
//        }
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .shadow(radius: 5)
//        //.padding()
//    }
//}










struct MyPreview : PreviewProvider {
    static var url : String = "http://localhost:8080/retrieve?rubric=sport&date=2024-09-1&top=-1&language=slo"
    static var previews : some View {
        ContentView()
    }
}











