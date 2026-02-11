//
//  DSCardListCell.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Standard Card List Cell
/// 包含：图标、标题、副标题、箭头、卡片背景
class DSCardListCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let cardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = DSColor.backgroundSecondary
        v.layer.cornerRadius = DSSpacing.radiusMedium
        return v
    }()
    
    private let iconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = DSColor.brandLight
        v.layer.cornerRadius = DSSpacing.radiusSmall
        return v
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.brand
        return iv
    }()
    
    private let titleLabel = DSLabel(style: .listTitle)
    private let subtitleLabel = DSLabel(style: .listSubtitle)
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = DSColor.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(cardContainer)
        cardContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(DSSpacing.xs)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
        }
        
        cardContainer.addSubview(iconContainer)
        iconContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(DSSpacing.m)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
            make.top.greaterThanOrEqualToSuperview().offset(DSSpacing.m)
            make.bottom.lessThanOrEqualToSuperview().offset(-DSSpacing.m)
        }
        
        iconContainer.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        cardContainer.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-DSSpacing.m)
            make.centerY.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(20)
        }
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = DSSpacing.xxs
        textStack.alignment = .leading
        
        cardContainer.addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.left.equalTo(iconContainer.snp.right).offset(DSSpacing.m)
            make.right.equalTo(arrowImageView.snp.left).offset(-DSSpacing.s)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(DSSpacing.m)
            make.bottom.lessThanOrEqualToSuperview().offset(-DSSpacing.m)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.cardContainer.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardContainer.backgroundColor = highlighted ? DSColor.backgroundSecondary.withAlphaComponent(0.8) : DSColor.backgroundSecondary
        }
    }
    
    // MARK: - Public Config
    func configure(title: String, subtitle: String? = nil, iconName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil)
        iconImageView.image = UIImage(systemName: iconName)
    }
}
