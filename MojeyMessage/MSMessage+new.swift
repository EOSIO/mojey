//
//  MSMessage+init.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/23/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import Messages

extension MSMessage {

    static func new(session: MSSession?, text: String?, image: UIImage?, query: [String:String]) -> MSMessage {

        let message: MSMessage
        if let session = session {
            print("SESSION = \(session)")
            message = MSMessage(session: session)
        } else {
            print("NO SESSION")
            message = MSMessage()
        }
        let layout = MSMessageTemplateLayout()
        layout.trailingCaption = text
        layout.image = image
        let liveLayout = MSMessageLiveLayout(alternateLayout: layout)
        message.layout = liveLayout
        message.summaryText = text

        var components = URLComponents()
        components.queryItems = [URLQueryItem]()
        for (name, value) in query {
            components.queryItems?.append(URLQueryItem(name: name, value: value))
        }
        message.url = components.url
        print("Message URL: \(message.url?.absoluteString ?? "")")
        return message

    }

}
