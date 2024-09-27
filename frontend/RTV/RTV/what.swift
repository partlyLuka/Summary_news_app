import Foundation
import SwiftUI

struct a: View {
    var body: some View {
        Image("slovenija")
    }
}

struct b: PreviewProvider {
    static var previews: some View {  // Specify the return type and correct the previews property
        a()
    }
}

