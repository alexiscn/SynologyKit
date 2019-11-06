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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func cleanButtonClicked(_ sender: Any) {
        LoginManager.shared.clean()
    }
}

