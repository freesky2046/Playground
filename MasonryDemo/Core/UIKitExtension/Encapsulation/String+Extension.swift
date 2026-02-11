//
//  String+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import UIKit
import CryptoKit

extension String {
    /// iOS 13+：计算字符串的MD5哈希值
    var md5: String {
        let data = Data(utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 计算字符串宽度
    /// - Parameter font: 字体
    /// - Returns: 宽度
    func calculateWidth(font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.width)
    }
    
    /// 计算字符串高度
    /// - Parameters:
    ///   - maxWidth: 最大宽度
    ///   - font: 字体
    ///   - lineBreakMode: 换行模式，默认为 .byWordWrapping
    /// - Returns: 高度
    func calculateHeight(maxWidth: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        // 创建段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: attributes,
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
