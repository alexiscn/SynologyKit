//
//  BrowserTableViewCell.swift
//  SynologyKitExample
//
//  Created by alexiscn on 2019/11/6.
//  Copyright © 2019 alexiscn. All rights reserved.
//

import UIKit
import Kingfisher
import SynologyKit

protocol BrowserTableViewCellDelegate: AnyObject {
    func didTapMoreButton(model: BrowserModel)
}

class BrowserTableViewCell: UITableViewCell {
    
    weak var delegate: BrowserTableViewCellDelegate?
    
    private let iconImageView: UIImageView
        
    private let infoStackView: UIStackView
    
    private let titleLabel: UILabel
    
    private let subTitleLabel: UILabel
    
    private var model: BrowserModel?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        
        titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        subTitleLabel = UILabel()
        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.textColor = UIColor.systemGray2
        
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
        
        let moreButton = UIButton(type: .custom)
        moreButton.addTarget(self, action: #selector(handleMoreButtonClicked), for: .touchUpInside)
        moreButton.frame.size = CGSize(width: 36, height: 36)
        moreButton.setImage(UIImage(named: "More_40x40_"), for: .normal)
        accessoryView = moreButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleMoreButtonClicked() {
        if let model = model {
            delegate?.didTapMoreButton(model: model)
        }
    }
    
    func update(_ model: BrowserModel, showThumb: Bool, client: SynologyClient) {
        self.model = model
        if model.isDirectory {
            iconImageView.image = UIImage(named: "Folder_40x40_")
        } else {
            if showThumb {
                let thumbURL = client.thumbURL(path: model.path)
                iconImageView.kf.setImage(with: thumbURL)
            } else {
                iconImageView.image = UIImage(named: "File_40x40_")
            }
        }
        titleLabel.text = model.name
        //subTitleLabel.text = // TODO
    }
}
