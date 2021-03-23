//
//  PurchaseButton.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/23/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct PurchaseButton: View {

    struct Layout {
        var width: CGFloat
        var height: CGFloat
        var foregroundColor: Color
        var backgroundColor: Color
        var cornerRadius: CGFloat
        var font: Font
    }

    private var price: String
    private var isPurchasing: Bool
    private var layout: Layout
    private var action: ()->Void

    private let activityCircleLayout = SegmentedActivityCircle.Layout(inset: 4, innerRadius: 10, numSegments: 10, segmentWidth: 0.5)

    init(price: String, isPurchasing: Bool, layout: Layout, action: @escaping ()->Void) {
        self.price = price
        self.isPurchasing = isPurchasing
        self.layout = layout
        self.action = action
    }

    var body: some View {
        Group {
            if (isPurchasing) {
                SegmentedActivityCircle(layout: activityCircleLayout)
                    .frame(minWidth: layout.width, maxWidth: layout.width, minHeight: layout.height, maxHeight: layout.height, alignment: .center)
                    .background(layout.backgroundColor)
                    .foregroundColor(layout.foregroundColor)
                    .cornerRadius(layout.cornerRadius)

            } else {
                Button(action: action) {
                    Text(price)
                        .frame(minWidth: layout.width, maxWidth: layout.width, minHeight: layout.height, maxHeight: layout.height, alignment: .center)
                        .font(layout.font)
                        .background(layout.backgroundColor)
                        .foregroundColor(layout.foregroundColor)
                        .cornerRadius(layout.cornerRadius)
                }
            }
        }
    }
}
