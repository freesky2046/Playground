//
//  String+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation
import CryptoKit

extension String {
    /// iOS 13+：计算字符串的MD5哈希值
    var md5: String {
        let data = Data(utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
