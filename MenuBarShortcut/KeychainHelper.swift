//
//  KeychainHelper.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 25/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Foundation

class KeychainHelper {
    
    static let keyPassword = "MenuBarShortcut_PASSWORD"
    static let keySecret = "MenuBarShortcut_SECRET"
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    static func listPasswordAccounts() throws -> [String] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: keyPassword,
        kSecMatchLimit as String: kSecMatchLimitAll,
        kSecReturnAttributes as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItems = item as? [[String : Any]]
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        var accounts: [String] = []
        for existingItem in existingItems {
            if let account = existingItem[kSecAttrAccount as String] as? String {
                accounts.append(account)
            }
        }
        return accounts
    }
    
    static func hasSecret(for account: String) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: keySecret,
        kSecAttrAccount as String: account,
        kSecMatchLimit as String: kSecMatchLimitOne]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            return true
        }
        
        return false
    }
    
    static func getPassword(for account: String) -> String? {
        return try? searchItem(key: keyPassword, account: account)
    }
    
    static func getSecret(for account: String) -> String? {
        return try? searchItem(key: keySecret, account: account)
    }
    
    private static func searchItem(key keyLabel: String, account: String) throws -> String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: keyLabel,
        kSecAttrAccount as String: account,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let passwordData = item as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
}
