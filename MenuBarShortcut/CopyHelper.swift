//
//  CopyHelper.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 25/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Foundation
import AppKit

class CopyHelper {
    
    private static var savedPasteboardItems: [NSPasteboardItem]?
    private static var copyCount: Int = 0
    
    static func copyText(_ stringToCopy: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(stringToCopy, forType: .string)
        
        NotificationHelper.sendNotification("Copiado para a área de transferência")
    }
    
    static func copyTempText(_ stringToCopy: String, for seconds: TimeInterval = 10) {
        let pasteboard = NSPasteboard.general
        
        // Save current pasteboard
        if savedPasteboardItems == nil {
            var currentPasteboardItems: [NSPasteboardItem] = []
            pasteboard.pasteboardItems?.forEach({ (pasteboardItem) in
                let archivedItem = NSPasteboardItem()
                pasteboardItem.types.forEach { (pasteboardType) in
                    if let data = pasteboardItem.data(forType: pasteboardType) {
                        archivedItem.setData(data, forType: pasteboardType)
                    }
                }
                currentPasteboardItems.append(archivedItem)
            })
            savedPasteboardItems = currentPasteboardItems
        }
        
        copyText(stringToCopy)
        
        self.copyCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.copyCount -= 1
            if (self.copyCount == 0) {
                pasteboard.clearContents()
                if let pasteboardItems = self.savedPasteboardItems {
                    pasteboard.writeObjects(pasteboardItems)
                    self.savedPasteboardItems = nil
                    NotificationHelper.sendNotification("Conteúdo da area de transferência restaurado")
                } else {
                    NotificationHelper.sendNotification("Conteúdo removido da area de transferência")
                }
            }
        }
    }
}
