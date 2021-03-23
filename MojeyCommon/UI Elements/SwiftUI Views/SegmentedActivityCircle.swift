//
//  SegmentedActivityCircle.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/23/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI


struct SegmentedActivityCircle : Shape {

    struct Layout {
        var inset: CGFloat
        var innerRadius: CGFloat
        var numSegments: Int
        var segmentWidth: Double
    }

    private let layout: Layout


    init(layout: Layout) {
        self.layout = layout
    }

    func path(in rect: CGRect) -> Path {
        let fullSegmentDegrees: Double = 180.0 / Double(layout.numSegments)
        let segmentDegrees = fullSegmentDegrees * layout.segmentWidth
        let center = CGPoint(x:rect.size.width/2, y:rect.size.height/2)
        let radius = (rect.size.lesserDimension / 2) - layout.inset
        var p = Path()
        for s in 0..<layout.numSegments {
            let a = Double(s) * fullSegmentDegrees
            print(a)
            print(a+segmentDegrees)
            p.addArc(center: center, radius: radius, startAngle: .degrees(a), endAngle: .degrees(a+segmentDegrees), clockwise: true)

        }
        //p.stroke(lineWidth: 0.1)
        //return p
        //p.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: true)
        return p.strokedPath(.init(lineWidth: 3))

        //return p.strokedPath(.init(lineWidth: 3, dash: [5, 3], dashPhase: 10))
    }
}


