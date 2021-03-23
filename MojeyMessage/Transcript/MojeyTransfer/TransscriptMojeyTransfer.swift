//
//  TransscriptMojeyTransfer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/30/19.
//  Copyright © 2020 Mojey. All rights reserved.
//



import Foundation
import SwiftUI

struct TransscriptMojeyTransfer: View {

    class Model: ObservableObject {
        @Published var info: Info = .none
        @Published var targetDevice: Device = Device()
        @Published var isDim = false
        @Published var sendThanks = false

        var mojeyQuantities = [MojeyQuantity]()
    }

    enum Info {
        case none
        case success
        case error(error: String)
        case device(target: Device)
    }

    struct Device {
        let sent: String
        let device: String
        let name: String
        let icon: String

        init(sent: String = "", device: String = "", name:String = "", icon: String = "") {
            self.sent = sent
            self.device = device
            self.name = name
            self.icon = icon
        }
    }

    @ObservedObject var model: Model
    @State var isOverlayVisible: Bool = false

    private func overlay() -> AnyView {
        switch model.info {
        case .none:
            return AnyView(Spacer(minLength: 0))
        case .success:
            return AnyView(SuccessOverlay(device: self.model.targetDevice, isOverlayVisible: $isOverlayVisible, model: model))
        case let .error(error):
            return AnyView(ErrorFooter(error: error))
        case let .device(target):
            return AnyView(MyOtherDeviceOverlay(device: target, isOverlayVisible: $isOverlayVisible, model: model))
        }
    }



    private var shouldShowSuccessIndicator: Bool {
        switch model.info {
        case .success: return true
        default: return false
        }
    }


    var body: some View {
        GeometryReader { g in
            ZStack() {
                VStack(alignment: .center, spacing: 0) {
                    //Spacer(minLength: 4)
                    MojeyRow(mojeyQuantities: self.model.mojeyQuantities)
                        .frame(minHeight: g.size.height*0.8, maxHeight: g.size.height*0.8, alignment: .center)
                        .opacity(self.model.isDim ? 1 : 1)
                        .saturation(self.model.isDim ? 0.1 : 1)
                    Spacer(minLength: 0)
                    //self.footer()
                    //    .frame(minHeight: g.size.height*0.2, maxHeight: g.size.height*0.2, alignment: .center)

                }
                .onTapGesture(count: 1) {
                        self.isOverlayVisible.toggle()
                }
                if self.isOverlayVisible {
                    self.overlay()
                }
                if self.shouldShowSuccessIndicator {
                    IndicatorOverlay()
                }

            }

        }
        //.padding(10)
        .background(Color(white: self.model.isDim ? 0.1 : 0.2))
    }


    struct DeviceFooter: View {

        let targetDevice: Device
        @Binding var isOverlayVisible: Bool

        var body: some View {
            GeometryReader { g in
                HStack(spacing: 4) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(spacing: 4) {
                            Text(self.targetDevice.sent)
                                 .fontWeight(.semibold)
                                 .font(.system(size: g.size.height*0.25))
                                 .foregroundColor(.gray)
                             Text(self.targetDevice.device)
                                 .fontWeight(.semibold)
                                 .font(.system(size: g.size.height*0.25))
                                 .foregroundColor(.orange)
                        }
                        Text(self.targetDevice.name)
                            .font(.system(size: g.size.height*0.4))
                            .foregroundColor(.white)
                    }.opacity(self.isOverlayVisible ? 1 : 0)
                    Image(self.targetDevice.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(1)

                }.padding(4)
            }
        }
    }


    struct SuccessFooter: View {
        var body: some View {
            HStack(spacing: 4) {
                Spacer()
                Image("Icon-MiniCheck")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(1)
            }.padding(4)
        }
    }


    struct IndicatorOverlay: View {
        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Image("Icon-MiniCheck")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 16, maxWidth: 16, minHeight: 16, maxHeight: 16, alignment: .bottomTrailing)
            }.padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .allowsHitTesting(false)
        }
    }


    struct SuccessOverlay: View {
        var device: Device
        @Binding var isOverlayVisible: Bool
        @ObservedObject var model: Model

        var body: some View {
            VStack(alignment: .center, spacing: 4) {
                Spacer()
                Image(device.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(1)
                    .frame(minHeight: 25,  maxHeight: 25, alignment: .center)
                Text("Recieved here")
                    .fontWeight(.regular)
                    .font(.system(size: 12))
                    //.multilineTextAlignment(.center)
//                Text(device.name)
//                    .fontWeight(.semibold)
//                    .font(.system(size: 12))
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.orange)
                Spacer()
                ThanksButton(model: model)
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(10)
            .background(Color(white: 0.1).opacity(0.9))
            .onTapGesture(count: 1) {
                self.isOverlayVisible.toggle()
            }

        }
    }




    struct ThanksButton: View {
        @ObservedObject var model: Model
        var body: some View {
            Button(action: {
                if !self.model.sendThanks {
                    self.model.sendThanks = true
                }
            }) {
                Text("Thanks!")
                .fontWeight(.semibold)
                .font(.system(size: 14))
            }
            .frame(minWidth: 110,  maxWidth: 110, minHeight: 36, maxHeight: 36, alignment: .center)
            .foregroundColor(.white)
            .background(Color.orange)
            .cornerRadius(20)
            .clipped()
        }
    }

    struct MyOtherDeviceOverlay: View {
        var device: Device
        @Binding var isOverlayVisible: Bool
        @ObservedObject var model: Model

        var body: some View {
            VStack(alignment: .center, spacing: 4) {
                Spacer()
//                Image(device.icon)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//
//                    .padding(1)
//                    .frame(minHeight: 25,  maxHeight: 25, alignment: .center)
                Text("Sent to: \(device.device)")
                    .fontWeight(.regular)
                    .font(.system(size: 11))
                Text(device.name)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))

                Spacer()
                ThanksButton(model: model)
                Spacer()
                Text("To receive here send thanks!")
                         .fontWeight(.semibold)
                         .opacity(0.7)
                         .font(.system(size: 10))
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(10)
            .background(Color(white: 0.1).opacity(0.9))
            .allowsHitTesting(true)
            .onTapGesture(count: 1) {
                self.isOverlayVisible.toggle()
            }
        }
    }


    struct ErrorFooter: View {

        let error: String

        var body: some View {
            GeometryReader { g in
                HStack(spacing: 4) {
                    Spacer()
                    Text(self.error)
                        .fontWeight(.semibold)
                        .font(.system(size: g.size.height*0.35))
                        .foregroundColor(.orange)
                    Image("Icon-MiniAlert")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(1)
                }.padding(4)
            }
        }
    }

}


