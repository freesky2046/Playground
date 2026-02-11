//
//  DSAvatar.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Avatar Component
/// 用于展示用户头像，支持图片或首字母缩写
public class DSAvatar: UIView {
    
    public enum Size {
        case small    // 24pt
        case medium   // 32pt
        case large    // 48pt
        case xLarge   // 64pt
        case custom(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 32
            case .large: return 48
            case .xLarge: return 64
            case .custom(let val): return val
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 14
            case .large: return 20
            case .xLarge: return 26
            case .custom(let val): return val * 0.4
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    private lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    
    private var size: Size = .medium
    
    public init(size: Size = .medium) {
        self.size = size
        super.init(frame: .zero)
        setupUI()
    }
    
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
        backgroundColor = DSColor.brandLight // 默认背景
        layer.cornerRadius = size.value / 2
        clipsToBounds = true
        
        addSubview(initialsLabel)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        initialsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 设置固定大小约束
        snp.makeConstraints { make in
            make.width.height.equalTo(size.value)
        }
        
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = size.value / 2
    }
    
    // MARK: - Configuration
    
    /// 设置图片头像
    public func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.isHidden = false
        initialsLabel.isHidden = true
        backgroundColor = .clear 
    }
    
    /// 设置文字头像 (如用户姓名首字母)
    /// - Parameters:
    ///   - text: 显示的文字 (建议1-2个字符)
    ///   - backgroundColor: 背景色 (默认使用 Brand 颜色)
    public func setInitials(_ text: String, backgroundColor: UIColor = DSColor.brand) {
        initialsLabel.text = text.uppercased()
        initialsLabel.font = .systemFont(ofSize: size.fontSize, weight: .bold)
        initialsLabel.isHidden = false
        imageView.isHidden = true
        self.backgroundColor = backgroundColor
    }
}
