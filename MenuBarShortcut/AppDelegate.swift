//
//  AppDelegate.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 24/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem: NSStatusItem!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
        }
        self.statusBarItem.menu = MenuBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

