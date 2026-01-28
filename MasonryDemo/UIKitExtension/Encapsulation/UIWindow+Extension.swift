//
//  UIWindow+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/28.
//

import UIKit

extension UIWindow {
    // iOS 14+
    static var keywindow: UIWindow? {
        let result = UIApplication.shared.connectedScenes // connected Set<UIScene>
            .compactMap { $0 as? UIWindowScene } // all [UIWindowScene]
            .filter { $0.activationState == .foregroundActive } // foregroundActive [UIWindowScene]
            .flatMap { $0.windows } // 每个元素都有一个[windows] .若使用map,就是 [[windows]], 使用flatMap 压扁成[windows]
            .first { $0.isKeyWindow } // 取出第一个为keywindow的window
        return result
    }
}
