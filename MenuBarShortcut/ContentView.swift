//
//  ContentView.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 24/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var account: String = ""
    @State private var password: String = ""
    @State private var secret: String = ""
    
    @State private var showAccountValidation: Bool = false
    @State private var showPasswordSecretValidation: Bool = false
    @State private var showPasswordError: Bool = false
    @State private var showSecretError: Bool = false
    
    var body: some View {
        Form {
            VStack(alignment: .center, spacing: 16, content: {
                Section(header: Text("MenuBarShortcut")) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Conta", text: $account)
                        TextField("Senha", text: $password)
                        TextField("Secret", text: $secret).disableAutocorrection(true)
                    }
                    Button("Adicionar") {
                        guard (account != "") else {
                            showAccountValidation = true
                            return
                        }
                        showAccountValidation = false
                        
                        guard (password != "" || secret != "") else {
                            showPasswordSecretValidation = true
                            return
                        }
                        showPasswordSecretValidation = false
                        
                        if (password != "") {
                            if (KeychainHelper.addPassword(password, for: account)) {
                                showPasswordError = false
                            } else {
                                showPasswordError = true
                            }
                        }
                        if (secret != "") {
                            if (KeychainHelper.addSecret(secret, for: account)) {
                                showSecretError = false
                            } else {
                                showSecretError = true
                            }
                        }
                    }
                    if showAccountValidation {
                        Text("Campo Conta requerido").lineLimit(0)
                    }
                    if showPasswordSecretValidation {
                        Text("Campo Senha ou Secret requerido").lineLimit(0)
                    }
                    if showPasswordError {
                        Text("Não foi possível adicionar a Senha").lineLimit(0)
                    }
                    if showSecretError {
                        Text("Não foi possível adicionar o Secret").lineLimit(0)
                    }
                }
            }).padding()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
