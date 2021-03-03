//
//  AuthenticationHelper.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 26/02/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Foundation
import LocalAuthentication

class AuthenticationHelper {
    static func validateAuth(authorized: @escaping () -> Void, failure: @escaping () -> Void) {
        let myContext = LAContext()
        let myLocalizedReasonString = "copiar senha"

        var authError: NSError? = nil
        
        if myContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &authError) {
            myContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { (success, evaluateError) in
                if (success) {
                    authorized()
                } else {
                    failure()
                }
            }
        } else {
            failure()
        }
    }
}
