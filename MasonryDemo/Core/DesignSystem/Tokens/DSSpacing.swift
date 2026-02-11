//
//  DSSpacing.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import CoreGraphics
import Foundation

/// Design System Spacing & Layout Tokens
/// 遵循 4px/8px 栅格系统
public struct DSSpacing {
    
    // MARK: - Spacing (间距)
    /// 4pt
    public static let xxs: CGFloat = 4.0
    /// 8pt
    public static let xs: CGFloat = 8.0
    /// 12pt
    public static let s: CGFloat = 12.0
    /// 16pt (标准边距)
    public static let m: CGFloat = 16.0
    /// 20pt
    public static let l: CGFloat = 20.0
    /// 24pt
    public static let xl: CGFloat = 24.0
    /// 32pt
    public static let xxl: CGFloat = 32.0
    
    // MARK: - Corner Radius (圆角)
    /// 小圆角 4pt
    public static let radiusSmall: CGFloat = 4.0
    /// 中圆角 8pt (卡片标准)
    public static let radiusMedium: CGFloat = 8.0
    /// 大圆角 12pt
    public static let radiusLarge: CGFloat = 12.0
    /// 超大圆角 16pt (弹窗)
    public static let radiusXLarge: CGFloat = 16.0
}
