//
//  DSToast.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Toast Component
/// 用于展示简短的提示信息
public class DSToast: UIView {
    
    // MARK: - Style Enum
    public enum Style {
        case success
        case error
        case info
        
        var backgroundColor: UIColor {
            switch self {
            case .success: return DSColor.success
            case .error: return DSColor.error
            case .info: return UIColor(hex: 0x333333)
            }
        }
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    // MARK: - UI Components
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = DSTypography.caption
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private var style: Style = .info
    
    // MARK: - Initialization
    public init(message: String, style: Style = .info) {
        super.init(frame: .zero)
        self.style = style
        self.messageLabel.text = message
        
        setupUI()
        configureStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 8
        layer.masksToBounds = true
        alpha = 0
        
        addSubview(iconImageView)
        addSubview(messageLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.greaterThanOrEqualTo(20)
        }
    }
    
    private func configureStyle() {
        // Safe check for system images (SF Symbols)
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: style.iconName)
        }
    }
    
    // MARK: - Public Methods
    public static func show(message: String, style: Style = .info, in view: UIView? = nil, duration: TimeInterval = 2.0) {
        guard let targetView = view ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let toast = DSToast(message: message, style: style)
        targetView.addSubview(toast)
        
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.width.lessThanOrEqualTo(targetView.snp.width).multipliedBy(0.8)
        }
        
        // Animation
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    toast.alpha = 0
                }) { _ in
                    toast.removeFromSuperview()
                }
            }
        }
    }
}
