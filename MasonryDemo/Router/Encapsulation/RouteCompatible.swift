//
//  RouteCompatible.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit

protocol RouteCompatible: UIViewController {
    func handleParams(params: [String: String])
    static func customNavigation(params: [String: String]) -> Bool
}

extension RouteCompatible {
    // 默认实现
    func handleParams(params: [String: String]) {
        print("\(Self.self) 处理路由参数: \(params)")
    }
    
    // 自己处理导航
    static func customNavigation(params: [String: String]) -> Bool {
        false
    }

}




