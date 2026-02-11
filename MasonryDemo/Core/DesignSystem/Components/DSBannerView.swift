//
//  DSBannerView.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Banner Component
/// 用于展示页面级通知、警告或状态信息
public class DSBannerView: UIView {
    
    public enum Style {
        case info
        case success
        case warning
        case error
        case custom(backgroundColor: UIColor, textColor: UIColor, iconColor: UIColor)
        
        var backgroundColor: UIColor {
            switch self {
            case .info: return DSColor.brandLight
            case .success: return UIColor(hex: 0xE8F5E9) // Light Green
            case .warning: return UIColor(hex: 0xFFF3E0) // Light Orange
            case .error: return UIColor(hex: 0xFFEBEE) // Light Red
            case .custom(let bg, _, _): return bg
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .info: return DSColor.brand
            case .success: return UIColor(hex: 0x1B5E20) // Dark Green
            case .warning: return UIColor(hex: 0xE65100) // Dark Orange
            case .error: return UIColor(hex: 0xB71C1C) // Dark Red
            case .custom(_, let text, _): return text
            }
        }
        
        var iconColor: UIColor {
            switch self {
            case .info: return DSColor.brand
            case .success: return DSColor.success
            case .warning: return DSColor.warning
            case .error: return DSColor.error
            case .custom(_, _, let icon): return icon
            }
        }
        
        var defaultIconName: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            case .custom: return "star.fill"
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = DSSpacing.radiusMedium
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: DSLabel = {
        let label = DSLabel(style: .h3)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var messageLabel: DSLabel = {
        let label = DSLabel(style: .body)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - Properties
    
    public var onClose: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public convenience init(style: Style, title: String? = nil, message: String, showCloseButton: Bool = false) {
        self.init(frame: .zero)
        configure(style: style, title: title, message: message, showCloseButton: showCloseButton)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(closeButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(DSSpacing.m)
            make.top.equalToSuperview().offset(DSSpacing.m)
            make.width.height.equalTo(24)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.s)
            make.right.equalToSuperview().offset(-DSSpacing.s)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(DSSpacing.s)
            make.right.equalTo(closeButton.snp.left).offset(-DSSpacing.xs)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.xs)
            make.left.equalTo(titleLabel)
            make.right.equalTo(containerView).offset(-DSSpacing.m)
            make.bottom.equalToSuperview().offset(-DSSpacing.m)
        }
    }
    
    // MARK: - Configuration
    
    public func configure(style: Style, title: String? = nil, message: String, showCloseButton: Bool = false) {
        containerView.backgroundColor = style.backgroundColor
        
        iconImageView.image = UIImage(systemName: style.defaultIconName)
        iconImageView.tintColor = style.iconColor
        
        titleLabel.text = title
        titleLabel.textColor = style.textColor
        titleLabel.isHidden = title == nil
        
        messageLabel.text = message
        messageLabel.textColor = style.textColor
        
        closeButton.tintColor = style.textColor.withAlphaComponent(0.6)
        closeButton.isHidden = !showCloseButton
        
        // 如果没有标题，调整消息的布局使其与图标对齐
        if title == nil {
            messageLabel.snp.remakeConstraints { make in
                make.top.equalTo(iconImageView)
                make.left.equalTo(iconImageView.snp.right).offset(DSSpacing.s)
                make.right.equalTo(showCloseButton ? closeButton.snp.left : containerView.snp.right).offset(-DSSpacing.m)
                make.bottom.equalToSuperview().offset(-DSSpacing.m)
            }
            
            // 确保 Icon 不会超出底部 (防止文字过短时高度坍塌)
            iconImageView.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(DSSpacing.m)
                make.top.equalToSuperview().offset(DSSpacing.m)
                make.width.height.equalTo(24)
                make.bottom.lessThanOrEqualToSuperview().offset(-DSSpacing.m)
            }
        } else {
            // 恢复原布局
             titleLabel.snp.remakeConstraints { make in
                make.top.equalTo(iconImageView)
                make.left.equalTo(iconImageView.snp.right).offset(DSSpacing.s)
                make.right.equalTo(showCloseButton ? closeButton.snp.left : containerView.snp.right).offset(-DSSpacing.xs)
            }
            
            messageLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.xs)
                make.left.equalTo(titleLabel)
                make.right.equalTo(containerView).offset(-DSSpacing.m)
                make.bottom.equalToSuperview().offset(-DSSpacing.m)
            }
        }
    }
    
    @objc private func closeTapped() {
        onClose?()
        // 默认带动画隐藏
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.isHidden = true
        })
    }
}
