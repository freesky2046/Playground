//
//  RouteError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation

enum RouteError: Error, CustomStringConvertible {
    case invalidURL(String) // 无效URL
    case invalidScheme(String) // 错误的scheme
    case notFoundPath(String) // 无效的path
    
    var description: String {
        switch self {
        case .invalidURL(let url):
            return "无效的 URL: \(url)"
        case .invalidScheme(let expected):
            return "期望: \(expected)"
        case .notFoundPath(let host):
            return "未找到路径: \(host)"
        }
    }
}
