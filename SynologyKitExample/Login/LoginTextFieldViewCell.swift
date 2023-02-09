//
//  LoginTextFieldViewCell.swift
//  SynologyKitExample
//
//  Created by alexiscn on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit

class LoginTextFieldViewCell: UITableViewCell {
    
    private let valueTextField: UITextField
    
    private var model: LoginModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        valueTextField = UITextField()
        valueTextField.clearButtonMode = .whileEditing
        valueTextField.font = UIFont.systemFont(ofSize: 15)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.backgroundColor = .clear
        
        contentView.addSubview(valueTextField)
        
        valueTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(150)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTextFieldTextChanged(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: valueTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTextFieldTextChanged(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        if textField == valueTextField {
            model?.stringValue = textField.text
        }
    }
    
    func update(model: LoginModel) {
        self.model = model
        textLabel?.text = model.title
        valueTextField.placeholder = model.placeholder
        valueTextField.isSecureTextEntry = model.field == .password
        
        if let stringValue = model.stringValue {
            valueTextField.text = stringValue
        }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return valueTextField.becomeFirstResponder()
    }
}
