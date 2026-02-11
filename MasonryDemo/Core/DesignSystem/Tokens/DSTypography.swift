//
//  DSTypography.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit

/// Design System Typography Tokens
public struct DSTypography {
    
    // MARK: - Font Weights
    private static let regular = UIFont.Weight.regular
    private static let medium = UIFont.Weight.medium
    private static let bold = UIFont.Weight.bold
    
    // MARK: - Headings (标题)
    /// 大标题 - 24pt
    public static let h1 = UIFont.systemFont(ofSize: 24, weight: bold)
    /// 中标题 - 20pt
    public static let h2 = UIFont.systemFont(ofSize: 20, weight: bold)
    /// 小标题 - 18pt
    public static let h3 = UIFont.systemFont(ofSize: 18, weight: medium)
    
    // MARK: - Body (正文)
    /// 常规正文 - 16pt
    public static let body = UIFont.systemFont(ofSize: 16, weight: regular)
    /// 加粗正文 - 16pt
    public static let bodyBold = UIFont.systemFont(ofSize: 16, weight: bold)
    
    // MARK: - Subtext / Caption (辅助文字)
    /// 说明文字 - 14pt
    public static let caption = UIFont.systemFont(ofSize: 14, weight: regular)
    /// 最小说明 - 12pt
    public static let small = UIFont.systemFont(ofSize: 12, weight: regular)
    
    // MARK: - Semantic Aliases (语义化别名 - 列表与详情)
    /// 列表标题 (通常用 16pt Medium/Bold)
    public static let listTitle = UIFont.systemFont(ofSize: 16, weight: medium)
    /// 列表副标题/摘要 (通常用 14pt Regular)
    public static let listSubtitle = caption
    
    /// 详情页大标题 (通常用 22pt-24pt Bold)
    public static let detailTitle = h1
    /// 详情页正文 (通常用 16pt-17pt Regular) - 建议配合行间距使用
    public static let detailBody = UIFont.systemFont(ofSize: 17, weight: regular)
}
