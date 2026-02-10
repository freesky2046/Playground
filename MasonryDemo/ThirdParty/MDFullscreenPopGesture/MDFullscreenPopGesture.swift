//
//  MDFullscreenPopGesture.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/10.
//

import UIKit

public class MDFullscreenPopGesture {
    
    /// 启用全屏侧滑手势功能
    /// 建议在 AppDelegate 的 didFinishLaunchingWithOptions 中调用
    public static func configure() {
        // 交换 UIViewController 的 viewWillAppear
        UIViewController.methodExchange()
        
        // 交换 UINavigationController 的 pushViewController
        UINavigationController.pushMethodExchange()
    }
}
