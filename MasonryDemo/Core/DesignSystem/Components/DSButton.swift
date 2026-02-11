//
//  DSButton.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Standard Button
public class DSButton: UIButton {
    
    public enum Style {
        case primary    // 实心背景，白字
        case secondary  // 浅色背景，品牌色字
        case outline    // 边框，品牌色字
        case text       // 纯文字
    }
    
    public enum Size {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
        
        var font: UIFont {
            switch self {
            case .small: return .systemFont(ofSize: 14, weight: .medium)
            case .medium: return DSTypography.h3
            case .large: return DSTypography.h3
            }
        }
        
        var contentInsets: UIEdgeInsets {
            switch self {
            case .small: return UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            case .medium: return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            case .large: return UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
            }
        }
    }
    
    public var style: Style = .primary {
        didSet { updateStyle() }
    }
    
    public var size: Size = .medium {
        didSet { updateSize() }
    }
    
    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public init(style: Style = .primary, size: Size = .medium) {
        super.init(frame: .zero)
        self.style = style
        self.size = size
        setupUI()
        updateStyle()
        updateSize()
    }
    
    public convenience init(title: String, style: Style = .primary, size: Size = .medium) {
        self.init(style: style, size: size)
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = DSSpacing.radiusMedium
        layer.masksToBounds = true
    }
    
    public override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.intrinsicContentSize ?? .zero
        let width = labelSize.width + contentEdgeInsets.left + contentEdgeInsets.right
        // 保证最小宽度，或者直接使用计算宽度
        return CGSize(width: max(width, size.height), height: size.height)
    }
    
    private func updateSize() {
        titleLabel?.font = size.font
        contentEdgeInsets = size.contentInsets
        invalidateIntrinsicContentSize()
    }
    
    private func updateStyle() {
        switch style {
        case .primary:
            backgroundColor = DSColor.brand
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            
        case .secondary:
            backgroundColor = DSColor.brandLight
            setTitleColor(DSColor.brand, for: .normal)
            layer.borderWidth = 0
            
        case .outline:
            backgroundColor = .clear
            setTitleColor(DSColor.brand, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = DSColor.brand.cgColor
            
        case .text:
            backgroundColor = .clear
            setTitleColor(DSColor.brand, for: .normal)
            layer.borderWidth = 0
        }
    }
}
