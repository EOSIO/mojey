//
//  MessageStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/15/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class MessageStore {

    static let `default` = MessageStore()

    private var processedMessagesUrl: URL

    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    init() {
        processedMessagesUrl = MessageStore.getDocumentsDirectory().appendingPathComponent("processedMessages.plist")
    }

    func getProcessedMessageIds() -> [String] {
        guard let array = NSArray(contentsOf: processedMessagesUrl) else { return [String]() }
        return array as? [String] ?? [String]()
    }

    func addProcessedMessageId(_ id: String) {
        var array = getProcessedMessageIds()
        array.insert(id, at: 0)
        (array as NSArray).write(to: processedMessagesUrl, atomically: true)
    }

    func hasMessageBeenProcessed(id: String) -> Bool {
        let processedMessageIds = getProcessedMessageIds()
        return processedMessageIds.contains(id)
    }

}
