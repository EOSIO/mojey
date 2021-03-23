//
//  BadgedMojeyViewswift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/30/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct BadgedToken: View {

    let tokenQuantity: TokenQuantity

    var body: some View {
        GeometryReader { g in
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                if self.tokenQuantity.quantity > 0 {
                    Badge(
                        text: "\(self.tokenQuantity.quantity)",
                        height: g.size.height*0.2,
                        textColor: .white,
                        backgroundColor: Color(white: 0.3))
                        .offset(y:g.size.height*0.04)
                } else {
                    Spacer(minLength: g.size.height*0.2)
                }

                ZStack() {
                    Circle()
                        .fill(Color(hex: tokenQuantity.token.backgroundColor))
                        .shadow(color: .black, radius: 5, x: 0, y: 0)
                        .frame(width: g.size.width*0.9, height: g.size.width*0.9)

                    Text(tokenQuantity.token.name.prefix(1))
                        .frame(alignment: .center)
                        .font(.system(size: g.size.width*0.6))
                        .foregroundColor(Color(hex: tokenQuantity.token.primaryColor))

                }


            }
        }
    }

}



