//
//  LoginSwitchViewCell.swift
//  SynologyKitExample
//
//  Created by alexiscn on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit

class LoginSwitchViewCell: UITableViewCell {
    
    private let switchButton: UISwitch
    
    private var model: LoginModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        switchButton = UISwitch()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = switchButton
        switchButton.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func onSwitchValueChanged(_ sender: Any) {
        model?.boolValue = switchButton.isOn
        if let model = model {
            switch model.field {
            case .allowHTTPS:
                LoginManager.shared.allowHTTPS = switchButton.isOn
            default:
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(model: LoginModel) {
        self.model = model
        textLabel?.text = model.title
        switchButton.isOn = model.boolValue ?? false
    }
}
