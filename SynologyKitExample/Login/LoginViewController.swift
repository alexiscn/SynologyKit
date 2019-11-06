//
//  LoginViewController.swift
//  SynologyKitExample
//
//  Created by xu.shuifeng on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var loginSuccessCommand: RelayCommand?
    
    private var tableView: UITableView!
    
    private var dataSource: [LoginModel] = []
    
    private var loginButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        
        setupTableView()
                
        let doneButton = UIBarButtonItem(title: "Login",
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleDoneButtonClicked))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        self.loginButton = doneButton
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTextFieldDidChangedNotification(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
        
        checkLoginButton()
    }
    
    @objc private func handleDoneButtonClicked() {
        
    }
    
    @objc private func handleTextFieldDidChangedNotification(_ notification: Notification) {
        checkLoginButton()
    }
    
    private func checkLoginButton() {
        let items = dataSource.filter { $0.field != .allowHTTPS && $0.field != .remember }
        let none = items.filter { ($0.stringValue?.isEmpty ?? true) }
        loginButton?.isEnabled = none.count == 0
    }
    
    private func setupDataSource() {
        
        let address = LoginModel(field: .address, title: "Address")
        address.placeholder = "Address or QuickConnect ID"
        address.stringValue = LoginManager.shared.host

        let username = LoginModel(field: .account, title: "Account")
        username.placeholder = "Account"
        username.stringValue = LoginManager.shared.username

        let password = LoginModel(field: .password, title: "Password")
        password.placeholder = "Password"
        password.stringValue = LoginManager.shared.password

        let allowHTTPS = LoginModel(field: .allowHTTPS, title: "HTTPS")
        allowHTTPS.boolValue = LoginManager.shared.allowHTTPS

        let remember = LoginModel(field: .remember, title: "Remember me")
        remember.boolValue = LoginManager.shared.rememberMe

        dataSource = [address, username, password, allowHTTPS, remember]
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        tableView.register(LoginTextFieldViewCell.self, forCellReuseIdentifier: NSStringFromClass(LoginTextFieldViewCell.self))
        tableView.register(LoginSwitchViewCell.self, forCellReuseIdentifier: NSStringFromClass(LoginSwitchViewCell.self))
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataSource[indexPath.row]
        switch model.field {
        case .allowHTTPS, .remember:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LoginSwitchViewCell.self), for: indexPath) as! LoginSwitchViewCell
            cell.update(model: model)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LoginTextFieldViewCell.self), for: indexPath) as! LoginTextFieldViewCell
            cell.update(model: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

