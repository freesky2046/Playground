//
//  UIViewController+MDFullscreenPopGestureExtension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/10.
//


import UIKit



extension UIViewController {
    
    typealias WillAppearInjectClosure = (_ viewController: UIViewController, _ animated: Bool) -> Void

    private struct AssociatedObjectKeys {
        static var kmd_hideNavigationBarKey: UInt8 = 0
        static var kmd_willAppearInjectClosureKey: UInt8 = 0
        static var kmd_popGestureDisableKey: UInt8 = 0
    }
    
    // 会被桥接成nsnumber,因此不是copy属性而是strong属性策略
    var md_hideNavigationBar: Bool {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kmd_hideNavigationBarKey) as? Bool {
                return value
            }
            let defaultResult = false
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_hideNavigationBarKey, defaultResult, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return defaultResult
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_hideNavigationBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var md_popGestureDisable: Bool {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kmd_popGestureDisableKey) as? Bool {
                return value
            }
            let defaultResult = false
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_popGestureDisableKey, defaultResult, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return defaultResult
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_popGestureDisableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var md_willAppearInjectClosure: WillAppearInjectClosure? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kmd_willAppearInjectClosureKey) as? WillAppearInjectClosure {
                return value
            }
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_willAppearInjectClosureKey, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_willAppearInjectClosureKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    static func methodExchange() {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.swizzled_viewWillAppear(_:))
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc private func swizzled_viewWillAppear(_ animated: Bool) {
        self.swizzled_viewWillAppear(animated)
        self.md_willAppearInjectClosure?(self, animated)
    }
    
}
