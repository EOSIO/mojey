//
//  TranscriptThanks.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 1/28/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

struct TransscriptThanks: View {


    var body: some View {
        HStack(spacing: 4) {
            //Spacer()
            //Spacer(minLength: 10)
            Text("Thanks!")
              .fontWeight(.semibold)
              //.opacity(0.7)
              .font(.system(size: 22))
            //Spacer()

        }
        .frame(minWidth: 200,  maxWidth: 200, minHeight: 60, maxHeight: 60, alignment: .center)
        .background(Color(white: 0.2))
    }

}

