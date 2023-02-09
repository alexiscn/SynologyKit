//
//  LoginManager.swift
//  SynologyKitExample
//
//  Created by alexiscn on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import Foundation
import KeychainSwift

class LoginManager {
    
    struct Keys {
        static let host = "LoginManager_Host"
        static let username = "LoginManager_Username"
        static let password = "LoginManager_Password"
        static let allowHTTPS = "LoginManager_AllowHTTPS"
    }
    
    static let shared = LoginManager()
    
    let keychain = KeychainSwift(keyPrefix: "me.shuifeng.SynologyKitExample")
    
    var host: String? {
        get { return keychain.get(Keys.host) }
        set {
            if let value = newValue, !value.isEmpty {
                keychain.set(value, forKey: Keys.host)
            } else {
                keychain.delete(Keys.host)
            }
        }
    }
    var username: String? {
        get { return keychain.get(Keys.username) }
        set {
            if let value = newValue, !value.isEmpty {
                keychain.set(value, forKey: Keys.username)
            } else {
                keychain.delete(Keys.username)
            }
        }
    }
    
    var password: String? {
        get { return keychain.get(Keys.password) }
        set {
            if let value = newValue, !value.isEmpty {
                keychain.set(value, forKey: Keys.password)
            } else {
                keychain.delete(Keys.password)
            }
        }
    }
    
    var allowHTTPS: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.allowHTTPS) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.allowHTTPS) }
    }
    
    private init() {}
    
    func clean() {
        host = nil
        username = nil
        password = nil
    }
    
    func save(address: String, username: String, password: String) {
        self.host = address
        self.username = username
        self.password = password
    }
    
}
