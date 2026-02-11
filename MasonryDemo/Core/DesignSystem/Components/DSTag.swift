//
//  DSTag.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Tag/Badge Component
/// 用于展示状态、类别或标签
public class DSTag: UIView {
    
    public enum Style {
        case primary
        case secondary
        case outline
        case success
        case warning
        case error
        
        var backgroundColor: UIColor {
            switch self {
            case .primary: return DSColor.brand.withAlphaComponent(0.1)
            case .secondary: return DSColor.backgroundSecondary
            case .outline: return .clear
            case .success: return DSColor.success.withAlphaComponent(0.1)
            case .warning: return DSColor.warning.withAlphaComponent(0.1)
            case .error: return DSColor.error.withAlphaComponent(0.1)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .primary: return DSColor.brand
            case .secondary: return DSColor.textSecondary
            case .outline: return DSColor.textSecondary
            case .success: return DSColor.success
            case .warning: return DSColor.warning
            case .error: return DSColor.error
            }
        }
        
        var borderColor: UIColor? {
            switch self {
            case .outline: return DSColor.separator
            default: return nil
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    
    public init(text: String, style: Style = .primary) {
        super.init(frame: .zero)
        setupUI()
        configure(text: text, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        layer.cornerRadius = 4
        clipsToBounds = true
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }
    }
    
    // MARK: - Configuration
    
    public func configure(text: String, style: Style) {
        label.text = text
        label.textColor = style.textColor
        backgroundColor = style.backgroundColor
        
        if let borderColor = style.borderColor {
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
}
