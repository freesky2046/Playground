//
//  DSLabel.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit

/// Design System Label Factory
/// 方便快速创建符合规范的 Label
public class DSLabel: UILabel {
    
    public enum Style {
        case h1, h2, h3
        case body, bodyBold
        case caption, small
        
        // Semantic
        case listTitle, listSubtitle
        case detailTitle, detailBody
    }
    
    public init(text: String? = nil, style: Style, color: UIColor = DSColor.textPrimary) {
        super.init(frame: .zero)
        self.textColor = color
        self.numberOfLines = 0 // 默认多行，适合列表和详情
        applyStyle(style)
        
        if let text = text {
            setText(text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 内部保存当前样式以便 setText 使用
    private var currentStyle: Style = .body
    
    private func applyStyle(_ style: Style) {
        self.currentStyle = style
        switch style {
        case .h1: font = DSTypography.h1
        case .h2: font = DSTypography.h2
        case .h3: font = DSTypography.h3
        case .body: font = DSTypography.body
        case .bodyBold: font = DSTypography.bodyBold
        case .caption:
            font = DSTypography.caption
            if textColor == DSColor.textPrimary { textColor = DSColor.textSecondary }
        case .small:
            font = DSTypography.small
            if textColor == DSColor.textPrimary { textColor = DSColor.textSecondary }
            
        case .listTitle:
            font = DSTypography.listTitle
        case .listSubtitle:
            font = DSTypography.listSubtitle
            if textColor == DSColor.textPrimary { textColor = DSColor.textSecondary }
            
        case .detailTitle:
            font = DSTypography.detailTitle
        case .detailBody:
            font = DSTypography.detailBody
        }
    }
    
    /// 设置文本，对于详情页正文会自动应用行间距
    public func setText(_ text: String) {
        if currentStyle == .detailBody {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8 // 舒适的阅读间距
            paragraphStyle.alignment = .justified // 两端对齐更像文章
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: DSTypography.detailBody,
                .foregroundColor: self.textColor ?? DSColor.textPrimary,
                .paragraphStyle: paragraphStyle
            ]
            
            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        } else {
            self.text = text
        }
    }
}
