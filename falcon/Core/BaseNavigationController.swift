//
//  BaseNavigationController.swift
//  falcon
//
//  Created by Trae on 2026/2/12.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    // MARK: - Rotation Control
    // 将旋转控制权交给栈顶控制器
    
    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    
    // MARK: - Status Bar Style
    // 将状态栏样式控制权交给栈顶控制器
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
}
