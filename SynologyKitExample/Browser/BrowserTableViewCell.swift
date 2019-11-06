//
//  BrowserTableViewCell.swift
//  SynologyKitExample
//
//  Created by xu.shuifeng on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit

class BrowserTableViewCell: UITableViewCell {
    
    private let iconImageView: UIImageView
        
    private let infoStackView: UIStackView
    
    private let titleLabel: UILabel
    
    private let subTitleLabel: UILabel
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        
        titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.black
        
        subTitleLabel = UILabel()
        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.textColor = UIColor(white: 0, alpha: 0.4)
        
        infoStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        infoStackView.axis = .vertical
        infoStackView.spacing = 3
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(infoStackView)
        
        iconImageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        infoStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(64)
            make.trailing.equalToSuperview().offset(-72)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ model: BrowserModel) {
        //iconImageView.image = // TODO
        titleLabel.text = model.name
        //subTitleLabel.text = // TODO
        accessoryType = model.isDirectory ? .disclosureIndicator: .none
    }

}
