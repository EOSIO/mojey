//
//  BadgedMojeyViewswift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/30/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct Badge: View {

    let text: String
    let height: CGFloat
    let textColor: Color
    let backgroundColor: Color

    var body: some View {
        Text(self.text)
            .fontWeight(.semibold)
            .padding(self.height*0.3)
            .frame(minWidth: self.height, minHeight: self.height, maxHeight: self.height, alignment: .center)
            .background(self.backgroundColor)
            .foregroundColor(self.textColor)
            .font(.system(size: self.height*0.65))
            .cornerRadius(self.height*0.5)
    }

}


struct Badge_Preview: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 10) {
            Badge(text: "1", height: 40, textColor: .white, backgroundColor: .black)
            Badge(text: "20", height: 60, textColor: .white, backgroundColor: .gray)
            Badge(text: "880", height: 30, textColor: .white, backgroundColor: .blue)
        }

    }
}

