//
//  BadgedMojeyViewswift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/30/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct BadgedMojey: View {

    let mojeyQuantity: MojeyQuantity

    var body: some View {
        GeometryReader { g in
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                if self.mojeyQuantity.quantity > 1 {
                    Badge(
                        text: "\(self.mojeyQuantity.quantity)",
                        height: g.size.height*0.2,
                        textColor: .white,
                        backgroundColor: Color(white: 0.3))
                        .offset(y:g.size.height*0.04)
                } else {
                    Spacer(minLength: g.size.height*0.2)
                }

                Text(self.mojeyQuantity.mojey)
                    .frame(alignment: .center)
                    .font(.system(size: g.size.height*0.6))
                    .shadow(color: .black, radius: 5, x: 0, y: 0)

            }
        }
    }

}


struct BadgedMojeyView_Preview: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 30) {
            BadgedMojey(mojeyQuantity: MojeyQuantity(mojey: "😀", quantity: 3))
                .frame(width: 90, height: 110, alignment: .center)

            BadgedMojey(mojeyQuantity: MojeyQuantity(mojey: "👽", quantity: 321))
                .frame(width: 90, height: 130, alignment: .center)
        }
        .padding(100)
        .background(Color(white: 0.2))
    }
}
