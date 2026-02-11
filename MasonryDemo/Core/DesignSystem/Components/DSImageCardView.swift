//
//  DSImageCardView.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Image Card Component
/// 上图下文的卡片样式
public class DSImageCardView: UIView {
    
    // MARK: - UI Components
    
    public lazy var cardView: DSCardView = {
        let card = DSCardView()
        card.elevation = .medium
        return card
    }()
    
    public lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = DSColor.backgroundSecondary // 占位色
        return iv
    }()
    
    public lazy var titleLabel: DSLabel = {
        let label = DSLabel(style: .h3)
        label.numberOfLines = 2
        return label
    }()
    
    public lazy var subtitleLabel: DSLabel = {
        let label = DSLabel(style: .caption)
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 3
        return label
    }()
    
    public lazy var actionButton: DSButton = {
        let btn = DSButton(style: .outline, size: .small)
        return btn
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Add subviews to card content
        cardView.contentView.addSubview(imageView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(actionButton)
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.6) // 16:9 比例偏高一点
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(DSSpacing.m)
            make.left.equalToSuperview().offset(DSSpacing.m)
            make.right.equalToSuperview().offset(-DSSpacing.m)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.xs)
            make.left.right.equalTo(titleLabel)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(DSSpacing.m)
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-DSSpacing.m)
            make.height.equalTo(32)
            // make.width.greaterThanOrEqualTo(80)
        }
    }
    
    // MARK: - Configuration
    
    public func configure(image: UIImage?, title: String, subtitle: String?, actionTitle: String? = nil, actionHandler: (() -> Void)? = nil) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
            // Note: Handler storage would need a wrapper or button subclass to hold the closure easily, 
            // for now we assume the VC adds target or we implement a simple closure storage if needed.
            // But DSButton doesn't support closure action directly yet. 
            // We can just set the text and visibility here.
        } else {
            actionButton.isHidden = true
            
            // Remake constraints if button is hidden to close the gap
            subtitleLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.xs)
                make.left.right.equalTo(titleLabel)
                make.bottom.equalToSuperview().offset(-DSSpacing.m)
            }
        }
    }
}
