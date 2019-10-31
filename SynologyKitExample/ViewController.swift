//
//  ViewController.swift
//  SynologyKitExample
//
//  Created by xu.shuifeng on 2019/10/31.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit
import SynologyKit

class ViewController: UIViewController {

    private let quickID = "YOUR_QUICK_ID"
    
    private let username = "YOUR_USER_NAME"
    
    private let password = "PASSWORD"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connect()
    }

    private func connect() {
        SynologyKit.getServerInfo(quickID: quickID) { response in
            switch response {
            case .success(let auth):
                print(auth.command)
                if let host = auth.service?.relayIP, let port = auth.service?.relayPort {
                    SynologyKit.host = host
                    SynologyKit.port = port
                    self.login()
                } else {
                    print("Server Error")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func login() {
        SynologyKit.login(account: username, passwd: password) { response in
            switch response {
            case .success(let auth):
                print(auth.sid)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

