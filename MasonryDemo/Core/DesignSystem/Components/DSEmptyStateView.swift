//
//  DSEmptyStateView.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Empty State Component
/// 用于列表为空、网络错误或搜索无结果等场景
public class DSEmptyStateView: UIView {
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = DSSpacing.m
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.textPlaceholder
        return iv
    }()
    
    private lazy var titleLabel: DSLabel = {
        let label = DSLabel(style: .h3)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: DSLabel = {
        let label = DSLabel(style: .body)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var actionButton: DSButton = {
        let btn = DSButton(style: .primary, size: .medium)
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - Properties
    
    public var onAction: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public convenience init(imageName: String = "tray", title: String, message: String? = nil, actionTitle: String? = nil) {
        self.init(frame: .zero)
        configure(imageName: imageName, title: title, message: message, actionTitle: actionTitle)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(DSSpacing.xl)
        }
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
        
        // 设置默认图片大小
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        // 设置按钮点击
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // 增加按钮上方的间距
        stackView.setCustomSpacing(DSSpacing.l, after: messageLabel)
    }
    
    // MARK: - Configuration
    
    public func configure(imageName: String, title: String, message: String? = nil, actionTitle: String? = nil) {
        if let image = UIImage(systemName: imageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: imageName)
        }
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
    
    @objc private func buttonTapped() {
        onAction?()
    }
}
