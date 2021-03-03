//
//  ContentView.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 24/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16, content: {
            Text("Para configurar, adicione a senha e o secret no Keychain")
            VStack(alignment: .leading, spacing: 8) {
                Text("Senha: \(KeychainHelper.keyPassword)")
                Text("Secret: \(KeychainHelper.keySecret)")
            }
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
