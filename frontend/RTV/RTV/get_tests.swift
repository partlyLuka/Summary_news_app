//
//  get_tests.swift
//  RTV
//
//  Created by Luka Andrensek on 19. 9. 24.
//

import Foundation
import SwiftUI

struct vvv : View {
    //let url1 = "http://localhost:8080/menu"
    let url2 = "https://dcc9d6ef782c2a.lhr.life/retrieve?rubric=slovenija&date=2024-09-15&top=-1&language=slo"
    var host : String = "3cc317c4d880f4.lhr.life"
    @State var url = "not initalized"
    @State var content = "unloaded"
    let v = host_generateURL_retrieve(host: "lol", rubric: "slovenija", date: "2024-09-15", language: "slo")!
    var body : some View {
        VStack {
            Text(url)
            Text(content)
            Text("\(v)")
            
                .onAppear {
                    Task {
                        await fetch()
                    }
                }
        }
    }
    func fetch() async {
        do {
            url = host_generateURL_menu(host : host)!
            content = try await send_get(url : url)
        } catch {
            content = "went wrong"
        }
    }
}

struct ppp : PreviewProvider {
    static var previews : some View {
        vvv()
    }
}

