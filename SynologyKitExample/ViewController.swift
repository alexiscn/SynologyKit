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
    
    private var client: SynologyClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        let manager = LoginManager.shared
        if let address = manager.host, let username = manager.username, let password = manager.password {
            if address.contains(".") {
                let allowHTTPS = manager.allowHTTPS
                let port = allowHTTPS ? 5001: 5000
                client = SynologyClient(host: address, port: port, enableHTTPS: allowHTTPS)
            } else {
                 client = SynologyClient(host: address)
            }
            client?.login(account: username, passwd: password) { [weak self] response in
                switch response {
                case .success(let authRes):
                    self?.client?.updateSessionID(authRes.sid)
                    self?.handleLoginSuccess()
                    print(authRes.sid)
                case .failure(let error):
                    print(error.description)
                }
            }
        } else {
            let loginViewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cleanButtonClicked(_ sender: Any) {
        LoginManager.shared.clean()
    }
    
    private func handleLoginSuccess() {
        guard let client = client else { return }
        let browserVC = BrowserViewController(client: client)
        let navigationController = UINavigationController(rootViewController: browserVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

