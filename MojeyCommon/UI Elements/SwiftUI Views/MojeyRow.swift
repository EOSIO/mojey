//
//  BadgedMojeyViewswift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/30/19.
//  Copyright © 2020 Mojey. All rights reserved.
//


import Foundation
import SwiftUI

struct MojeyRow: View {

    let mojeyQuantities: [MojeyQuantity]

    private func xOffset(index: Int, size: CGSize) -> CGFloat {
        var aw = size.width - 60
        if aw > size.height * CGFloat(mojeyQuantities.count) {
            aw = size.height * CGFloat(mojeyQuantities.count)
        }
        let wi = aw / CGFloat(mojeyQuantities.count)
        return (CGFloat(index) * wi) - (aw / 2) + (wi / 2)
    }

    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .center) {
                ForEach((0..<self.mojeyQuantities.count), id: \.self) {
                    BadgedMojey(mojeyQuantity: self.mojeyQuantities[$0])
                        .offset(x: self.xOffset(index: $0, size: g.size))
                }
            }
        }
    }

}


private func mojeyQuantities() -> [MojeyQuantity] {
      return [
            MojeyQuantity(mojey: "😀", quantity: 3),
            MojeyQuantity(mojey: "🥶", quantity: 1),
            MojeyQuantity(mojey: "👽", quantity: 4),
            MojeyQuantity(mojey: "😺", quantity: 88),
            MojeyQuantity(mojey: "🔥", quantity: 400)
      ]
  }

struct MojeyRow_Preview: PreviewProvider {


    static var previews: some View {
        VStack(alignment: .center, spacing: 30) {
            MojeyRow(mojeyQuantities: mojeyQuantities())
                .frame(minWidth: 200, maxWidth: 260, minHeight: 110, maxHeight: 110, alignment: .center)
        }
        .background(Color(white: 0.2))

    }

}

