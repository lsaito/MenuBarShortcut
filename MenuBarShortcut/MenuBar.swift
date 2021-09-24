//
//  MenuBar.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 24/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

//OneTimePassword -> https://github.com/mattrubin/OneTimePassword
//Base32 -> https://github.com/norio-nomura/Base32/blob/master/Sources/Base32/Base32.swift

class MenuBar: NSMenu {
    
    private static let passwordStringTitle = "Senha"
    private static let VPNStringTitle = "VPN"
    private static let tokenStringTitle = "Token OTP"
    
    private var tokenListMenuItem: [MenuBarTokenItem] = []
    
    convenience init() {
        self.init(title: "")
    }
    
    override init(title: String) {
        super.init(title: title)
        
        setupMenu()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupMenu()
    }
    
    private func setupMenu() {
        addAccountsItems()
        addSeparatorItem()
        addQuitItem()
    }
    
    private func addSeparatorItem() {
        self.addItem(NSMenuItem.separator())
    }
    
    private func addContentView() {
        let contentView = ContentView()
        
        let menuItemView = NSMenuItem()
        let menuView = NSHostingView(rootView: contentView)
        menuView.frame = NSRect(x: 0, y: 0, width: 200, height: 200)
        menuItemView.view = menuView
        self.addItem(menuItemView)
    }
    
    private func addAccountsItems() {
        guard let accounts = try? KeychainHelper.listAccounts() else {
            addContentView()
            return
        }
        
        for (index, account) in accounts.enumerated() {
            if (KeychainHelper.hasPassword(for: account)) {
                let menuItemPassword = NSMenuItem()
                menuItemPassword.title = "\(Self.passwordStringTitle) \(account)"
                menuItemPassword.action = #selector(copyPassword(_:))
                menuItemPassword.target = self
                self.addItem(menuItemPassword)
                
                if (KeychainHelper.hasSecret(for: account)) {
                    let menuItemVPN = NSMenuItem()
                    menuItemVPN.title = "\(Self.VPNStringTitle) \(account)"
                    menuItemVPN.action = #selector(copyVPN(_:))
                    menuItemVPN.target = self
                    self.addItem(menuItemVPN)
                }
            }
            
            if (KeychainHelper.hasSecret(for: account)) {
                guard let secret = KeychainHelper.getSecret(for: account), let urlOtp = URL(string: secret), let token = Token(url: urlOtp) else { return }
                
                let menuItemToken = MenuBarTokenItem(account: account, token: token)
                menuItemToken.title = "\(Self.tokenStringTitle) \(account)"
                menuItemToken.action = #selector(copyToken(_:))
                menuItemToken.target = self
                
                self.addItem(menuItemToken)
                
                tokenListMenuItem.append(menuItemToken)
            }
            
            if (index+1 < accounts.count) {
                self.addSeparatorItem()
            }
        }
    }
    
    @objc func copyPassword(_ sender: NSMenuItem) {
        AuthenticationHelper.validateAuth(authorized: {
            let stringTitle = Self.passwordStringTitle
            let titleLenght = stringTitle.count + 1
            
            guard sender.title.count > titleLenght else { return }
            
            let account = String(sender.title.suffix(sender.title.count - titleLenght))
            
            guard let password = KeychainHelper.getPassword(for: account) else { return }
            
            CopyHelper.copyTempText(password)
        }) {
            NotificationHelper.sendNotification("Falha na autorização")
        }
    }
    
    @objc func copyVPN(_ sender: NSMenuItem) {
        AuthenticationHelper.validateAuth(authorized: {
            let stringTitle = Self.VPNStringTitle
            let titleLenght = stringTitle.count + 1
            
            guard sender.title.count > titleLenght else { return }
            
            let account = String(sender.title.suffix(sender.title.count - titleLenght))
            
            guard let password = KeychainHelper.getPassword(for: account), let secret = KeychainHelper.getSecret(for: account) else { return }
            
            guard let urlOtp = URL(string: secret), let token = Token(url: urlOtp), let otp = token.currentPassword else { return }
            
            CopyHelper.copyTempText("\(password)\(otp)")
        }) {
            NotificationHelper.sendNotification("Falha na autorização")
        }
    }
    
    @objc func copyToken(_ sender: NSMenuItem) {
        guard let menuTokenItem = sender as? MenuBarTokenItem, let otp = menuTokenItem.token.currentPassword else { return }
        
        CopyHelper.copyTempText(otp)
    }
    
    private func addQuitItem() {
        let menuItemQuit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        self.addItem(menuItemQuit)
    }
}

private class MenuBarTokenItem: NSMenuItem {
    let account: String
    let token: Token
    
    init(account: String, token: Token) {
        self.account = account
        self.token = token
        super.init(title: "", action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTokenTimeRemaining() -> Int? {
        switch self.token.generator.factor {
        case .counter( _):
            return nil
        case .timer(period: let period):
            let currentTime = Date()
            let timeSinceEpoch = currentTime.timeIntervalSince1970
            let timeElapsed = timeSinceEpoch.truncatingRemainder(dividingBy: period)
            let timeRemaining = UInt64(period - timeElapsed)
            
            return Int(timeRemaining)
        }
    }
    
    func updateToken() {
        self.title = "\(account): \(token.currentPassword ?? "-")"
    }
}
