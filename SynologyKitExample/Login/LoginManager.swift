//
//  LoginManager.swift
//  SynologyKitExample
//
//  Created by xu.shuifeng on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import Foundation
import KeychainSwift

class LoginManager {
    
    struct Keys {
        static let host = "LoginManager_Host"
        static let port = "LoginManager_Port"
        static let quickID = "LoginManager_QuickID"
        static let username = "LoginManager_Username"
        static let password = "LoginManager_Password"
        
        static let allowHTTPS = "LoginManager_AllowHTTPS"
        static let rememberMe = "LoginManager_RememberMe"
    }
    
    static let shared = LoginManager()
    
    let keychain = KeychainSwift(keyPrefix: "me.shuifeng.SynologyKitExample")
    
    var sessionID: String?
    
    var isLogined: Bool { return sessionID != nil }
    
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
    
    var port: Int? {
        get { return UserDefaults.standard.value(forKey: Keys.port) as? Int  }
        set { UserDefaults.standard.set(newValue, forKey: Keys.port) }
    }
    
    var quickID: String? {
        get { return keychain.get(Keys.quickID) }
        set {
            if let value = newValue, !value.isEmpty {
                keychain.set(value, forKey: Keys.quickID)
            } else {
                keychain.delete(Keys.quickID)
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
    
    var rememberMe: Bool {
        get { return (UserDefaults.standard.value(forKey: Keys.rememberMe) as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Keys.rememberMe) }
    }
    
    private init() {}
    
 
    func clean() {
        host = nil
        port = nil
        quickID = nil
        username = nil
        password = nil
    }
    
}
