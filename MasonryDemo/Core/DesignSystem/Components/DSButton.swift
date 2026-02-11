//
//  DSButton.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit

/// Design System Standard Button
public class DSButton: UIButton {
    
    public enum Style {
        case primary    // 实心背景，白字
        case secondary  // 浅色背景，品牌色字
        case outline    // 边框，品牌色字
        case text       // 纯文字
    }
    
    public var style: Style = .primary {
        didSet { updateStyle() }
    }
    
    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public init(title: String, style: Style = .primary) {
        super.init(frame: .zero)
        self.style = style
        setTitle(title, for: .normal)
        setupUI()
        updateStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel?.font = DSTypography.h3
        layer.cornerRadius = DSSpacing.radiusMedium
        layer.masksToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: DSSpacing.s, left: DSSpacing.l, bottom: DSSpacing.s, right: DSSpacing.l)
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
