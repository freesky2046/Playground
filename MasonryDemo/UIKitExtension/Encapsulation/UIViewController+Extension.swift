//
//  UIViewController+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/28.
//

import UIKit

extension UIViewController {
    static var current: UIViewController? {
        guard let keywindow = UIWindow.keywindow else {
            return nil
        }
        return Self.findTop(from: keywindow.rootViewController)
     }

     private static func findTop(from base: UIViewController?) -> UIViewController? {
         if let nav = base as? UINavigationController {
             return findTop(from: nav.visibleViewController)
         }
         if let tab = base as? UITabBarController {
             return findTop(from: tab.selectedViewController)
         }
         if let presented = base?.presentedViewController {
             return findTop(from: presented)
         }
         return base
     }
}


