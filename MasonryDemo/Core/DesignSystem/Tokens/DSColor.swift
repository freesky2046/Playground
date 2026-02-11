//
//  DSColor.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit

/// Design System Color Tokens
/// 使用结构体而非枚举，以便于扩展和计算属性
public struct DSColor {
    
    // MARK: - Brand Colors (品牌色)
    /// 主品牌色 - 珊瑚红 (Coral Red)
    public static let brand = UIColor(hex: 0xFF6B6B)
    /// 品牌辅助色 - 浅粉 (Blush)
    public static let brandLight = UIColor(hex: 0xFFEEEE)
    
    // MARK: - Semantic Colors (语义色)
    public static let success = UIColor(hex: 0x34C759)
    public static let warning = UIColor(hex: 0xFF9500)
    public static let error = UIColor(hex: 0xFF3B30)
    
    // MARK: - Background Colors (背景色 - 支持深色模式)
    /// 一级背景（页面底色）
    public static var backgroundPrimary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
    }
    
    /// 二级背景（卡片、列表项）
    public static var backgroundSecondary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x1C1C1E) : UIColor(hex: 0xF2F2F7)
        }
    }
    
    // MARK: - Text Colors (文字色)
    /// 主要文字（标题、正文）
    public static var textPrimary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: 0x000000)
        }
    }
    
    /// 次要文字（说明、辅助信息）
    public static var textSecondary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x8E8E93) : UIColor(hex: 0x8A8A8E)
        }
    }
    
    /// 占位文字
    public static var textPlaceholder: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x636366) : UIColor(hex: 0xC7C7CC)
        }
    }
    
    // MARK: - TabBar Colors
    /// TabBar 选中颜色 (通常跟随品牌色)
    public static var tabBarSelected: UIColor {
        return brand
    }
    
    /// TabBar 未选中颜色 (通常是灰色)
    public static var tabBarUnselected: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x8E8E93) : UIColor(hex: 0x999999)
        }
    }
    
    /// TabBar 背景色 (毛玻璃下的底色)
    public static var tabBarBackground: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x1C1C1E) : UIColor.white
        }
    }

    // MARK: - Separator (分割线)
    public static var separator: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: 0x38383A) : UIColor(hex: 0xE5E5EA)
        }
    }
}

// 简单的 Hex 扩展辅助
private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
