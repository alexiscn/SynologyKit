//
//  LoginModel.swift
//  SynologyKitExample
//
//  Created by xu.shuifeng on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import Foundation

class LoginModel {
    
    enum Field {
        case address
        case account
        case password
        case allowHTTPS
        case remember
    }
    
    var field: Field
    
    var title: String
    
    var placeholder: String? = nil
    
    var stringValue: String? = nil
    
    var boolValue: Bool? = nil
    
    init(field: Field, title: String) {
        self.field = field
        self.title = title
    }
}
