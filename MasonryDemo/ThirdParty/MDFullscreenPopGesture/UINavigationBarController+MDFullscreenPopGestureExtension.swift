//
//  UINavigationBarController+MDFullscreenPopGestureExtension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/10.
//

import Foundation
import UIKit

extension UINavigationController {
    private struct AssociatedObjectKeys {
        static var kmd_navigationControllerDelegateKey: UInt8 = 0
        static var kmd_FullscreenPopGestureRecognizerKey: UInt8 = 0
    }
    
    // 会被桥接成nsnumber
    var md_navigationControllerDelegate: UINavigationBarControllerDelegate {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kmd_navigationControllerDelegateKey) as? UINavigationBarControllerDelegate {
                return value
            }
            
            let delegate = UINavigationBarControllerDelegate(navigationController: self)
            
            delegate.navigationController = self
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_navigationControllerDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return delegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_navigationControllerDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var md_FullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kmd_FullscreenPopGestureRecognizerKey) as? UIPanGestureRecognizer {
                return value
            }
            
            let gesture = UIPanGestureRecognizer()
            gesture.maximumNumberOfTouches = 1
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_FullscreenPopGestureRecognizerKey, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return gesture
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kmd_FullscreenPopGestureRecognizerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    static func pushMethodExchange() {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(UINavigationController.swizzled_pushViewController(_:animated:))
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                         let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(md_FullscreenPopGestureRecognizer) == false {
            self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(md_FullscreenPopGestureRecognizer)
            
            // 比较少人知道的知识 获取系统手势的target action,让自定义的接管
            if let targets = interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject] {
                if let targetObj = targets.first, let target = targetObj.value(forKey: "target") {
                    let action = NSSelectorFromString("handleNavigationTransition:")
                    md_FullscreenPopGestureRecognizer.addTarget(target, action: action)
                }
            }
    
            md_FullscreenPopGestureRecognizer.delegate = self.md_navigationControllerDelegate
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        let viewWillAppearClosure: WillAppearInjectClosure = { [weak self] viewController, animated in
            self?.setNavigationBarHidden(viewController.md_hideNavigationBar, animated: animated)
        }
        viewController.md_willAppearInjectClosure = viewWillAppearClosure
        
        let lastViewcontroller = self.viewControllers.last
        // 想象一下场景, rootviewcontroller初始化后没有这个闭包,从上一个页面返回就不会调用刷新导航栏的方法
        if let lastViewcontroller, lastViewcontroller.md_willAppearInjectClosure == nil {
            lastViewcontroller.md_willAppearInjectClosure = viewWillAppearClosure
        }
        
        // 必须调用原始实现，否则 Push 动作不会发生！
        self.swizzled_pushViewController(viewController, animated: animated)
    }
}

class UINavigationBarControllerDelegate: NSObject {
    weak var navigationController: UINavigationController?
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension UINavigationBarControllerDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count ?? 0 <= 1 {
            return false
        }
        let current = navigationController?.viewControllers.last
        if current?.md_popGestureDisable == true {
            return false
        }
        // 比较少人知道的知识 动画中
        if let isTransitioning = navigationController?.value(forKey: "_isTransitioning") as? Bool, isTransitioning == true {
            return false
        }
        
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: panGesture.view)
            if translation.x <= 0 {
                return false
            }
        }
        
        return true
    }
}
