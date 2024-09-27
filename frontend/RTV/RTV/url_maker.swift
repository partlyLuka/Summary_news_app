//
//  url_maker.swift
//  RTV
//
//  Created by Luka Andrensek on 18. 9. 24.
//

import Foundation
import SwiftUI

func host_generateURL_get(host : String , uuid : String) -> String? {
    return "http://" + host + "/get?uuid=" + uuid
}

func host_generateURL_menu(host: String) -> String? {
    if host == "localhost:8080" {
        return "http://" + host + "/menu"
    } else {
        return "https://" + host + "/menu"
    }
    
    
}

func host_generateURL_retrieve(host: String, rubric: String, date: String, language: String) -> String? {
    if host == "localhost:8080" {
        return "http://" + host + "/retrieve?" +
        "rubric=" + rubric + "&" +
        "date=" + date + "&" +
        "top=-1&" +
        "language=" + language
    } else {
        return "https://" + host + "/retrieve?" +
        "rubric=" + rubric + "&" +
        "date=" + date + "&" +
        "top=-1&" +
        "language=" + language
    }
}

func host_generateURL_summary(host: String, rubric: String, sum_type: String, week_number: String, language : String) -> String? {
    if host == "localhost:8080" {
        return "http://" + host + "/summary?" +
        "rubric=" + rubric + "&" +
        "sum_type=" + sum_type + "&" +
        "week_number=" + week_number + "&" +
        "language=" + language
    } else {
        return "https://" + host + "/summary?" +
        "rubric=" + rubric + "&" +
        "sum_type=" + sum_type + "&" +
        "week_number=" + week_number + "&" +
        "language=" + language
    }
}

func _host_generateURL_summary(host : String, rubric:String, sum_type:String, week_number:String, language:String) -> String? {
    var components = URLComponents()
    var port : Int? {
        if host == "localhost" {
            8080
        } else {nil}
    }
    components.scheme = "http"
    components.host = host
    components.port = port
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


struct t : PreviewProvider {
    static var url = host_generateURL_menu(host : "localhost")
    static var previews : some View {
        Text(url!)
    }
}
