//
//  MojeyStorefrontView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/12/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct MojeyStorefrontView: View {

    @EnvironmentObject var purchasingSelection: MojeyStorefrontPurchasingSelection

    private let packs: [MojeyPack]

    init(packs: [MojeyPack]) {
        self.packs = packs
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .background(Color(white: 0.2))
                .frame(width: 60, height: 6, alignment: .center)
                .padding(10)
            ForEach(packs, id: \.self) { pack in
                MojeyPackRow(pack: pack)
            }
            Spacer()
        }
        .frame(alignment: .topLeading)
    }

    
    struct MojeyPackRow: View {

        @EnvironmentObject var purchasingSelection: MojeyStorefrontPurchasingSelection

        private let pack: MojeyPack
        private let buttonLayout = PurchaseButton.Layout(
            width: 72,
            height: 36,
            foregroundColor: .black,
            backgroundColor: .white,
            cornerRadius: 18,
            font: .headline)

        private var isPurchasing: Bool {
            return self.pack.productIdentifier == self.purchasingSelection.productIdentifier
        }

        private var isDisabled: Bool {
            return self.purchasingSelection.productIdentifier != nil && self.pack.productIdentifier != self.purchasingSelection.productIdentifier
        }

        init(pack: MojeyPack) {
            self.pack = pack
        }

        var body: some View {
            HStack(alignment: .center, spacing: 6) {
                MojeyCount(count: pack.count)
                MojeyGrid(pack: pack).padding(10)
                Spacer()
                PurchaseButton(price: pack.price, isPurchasing: isPurchasing, layout: buttonLayout) {
                    if self.purchasingSelection.productIdentifier == nil {
                        self.purchasingSelection.productIdentifier = self.pack.productIdentifier
                    }
                }.padding(8)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .leading)
            .padding(12)
            .opacity(isDisabled ? 0.3 : 1)
            .disabled(isDisabled)
        }
    }


    struct MojeyCount: View {
        private let count: Int

        init(count: Int) {
            self.count = count
        }

        var body: some View {
            VStack(alignment: .center, spacing: 2) {
                Text("\(count)")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                Text("Mojey")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            .frame(minWidth: 70, maxWidth: 70, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .padding(6)
        }
    }


    struct MojeyGrid: View {

        private let itemSize = CGSize(width: 30, height: 30)
        private let pack: MojeyPack
        private let items: [[String]]

        init(pack: MojeyPack) {
            self.pack = pack
            self.items = pack.mojey.split(numberOfSubarrays: 3)
        }

        var body: some View {
            VStack(alignment: .center, spacing: 2) {
                MojeyGridRow(items: items[0], itemSize: itemSize, direction: .right, duration: 3)
                MojeyGridRow(items: items[1], itemSize: itemSize,  direction: .left, duration: 4.5)
                MojeyGridRow(items: items[2], itemSize: itemSize,  direction: .right, duration: 6)
            }
            .frame(minWidth: 110, maxWidth: 110, minHeight: 110, maxHeight: 110, alignment: .center)
            .background(Color(white: 0.2))
            .cornerRadius(25)
            .clipped()
        }
    }

    
    struct MojeyGridRow: View {
        enum Direction: CGFloat {
            case left = -1
            case right = 1
        }
        @State private var offset: CGFloat = 0
        private var duration: Double = 0
        private var direction: Direction = .left
        private var items: [String]
        private var itemSize: CGSize

        init(items: [String], itemSize: CGSize, direction: Direction, duration: Double) {
            self.items = items
            self.direction = direction
            self.duration = duration
            self.itemSize = itemSize
        }

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ForEach((0..<items.count * 3), id: \.self) {
                    Text(self.items[$0 % self.items.count])
                        .frame(minWidth: self.itemSize.width, maxWidth: self.itemSize.width, minHeight: self.itemSize.height, maxHeight: self.itemSize.height, alignment: .center)
                }
            }
            .offset(x: self.offset, y: 0)
            .onAppear {
                withAnimation(Animation.linear(duration: self.duration).repeatForever(autoreverses: false)) {
                    print(self.offset)
                    self.offset = CGFloat(self.items.count) * self.itemSize.width * self.direction.rawValue
                }
            }
        }
    }
}
