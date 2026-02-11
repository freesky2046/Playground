//
//  DSCardView.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Card Component
/// 通用卡片容器，提供标准的圆角、阴影和背景色
public class DSCardView: UIView {
    
    // MARK: - Properties
    
    /// 卡片内容容器（所有子视图应添加到此视图中）
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = DSColor.backgroundSecondary
        view.layer.cornerRadius = DSSpacing.radiusMedium
        view.clipsToBounds = true
        return view
    }()
    
    /// 阴影层级
    public enum Elevation {
        case none
        case low
        case medium
        case high
        
        var opacity: Float {
            switch self {
            case .none: return 0
            case .low: return 0.05
            case .medium: return 0.1
            case .high: return 0.15
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .none: return 0
            case .low: return 4
            case .medium: return 8
            case .high: return 16
            }
        }
        
        var offset: CGSize {
            switch self {
            case .none: return .zero
            case .low: return CGSize(width: 0, height: 2)
            case .medium: return CGSize(width: 0, height: 4)
            case .high: return CGSize(width: 0, height: 8)
            }
        }
    }
    
    public var elevation: Elevation = .low {
        didSet {
            applyShadow()
        }
    }
    
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
        backgroundColor = .clear
        
        // 阴影设置在自身 layer
        layer.masksToBounds = false
        applyShadow()
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func applyShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = elevation.opacity
        layer.shadowOffset = elevation.offset
        layer.shadowRadius = elevation.radius
    }
    
    // MARK: - Touch Handling
    
    // 如果需要点击效果，可以在这里添加
}
