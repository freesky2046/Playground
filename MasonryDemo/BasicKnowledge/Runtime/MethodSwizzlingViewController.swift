//
//  MethodSwizzlingViewController.swift
//  MasonryDemo
//
//  Created by User on 2026/02/10.
//

import UIKit
import SnapKit

// MARK: - 1. 扩展 UIViewController 进行方法交换
extension UIViewController {
    
    // 这是一个静态方法，用于在应用启动时执行交换
    // Swift 中通常使用 static let 的闭包立即执行特性来实现 dispatch_once
    static let swizzleViewWillAppear: Void = {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(hook_viewWillAppear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        // 核心交换逻辑
        // 如果是继承关系，先尝试 addMethod，成功说明父类没实现，直接交换；失败说明已存在，直接 exchange
        let didAddMethod = class_addMethod(
            UIViewController.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
        
        if didAddMethod {
            class_replaceMethod(
                UIViewController.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        print("✅ UIViewController.viewWillAppear 已成功交换")
    }()
    
    // MARK: - Swizzled Method
    // 注意：这里必须加 @objc
    @objc func hook_viewWillAppear(_ animated: Bool) {
        // 插入自定义逻辑
        let className = String(describing: type(of: self))
        print("🔍 [Hook] 即将显示控制器: \(className)")
        
        // 重点：调用“自己”，实际上会调用原来的 viewWillAppear
        // 看起来像递归，但因为方法实现已经被交换了，所以 hook_viewWillAppear 指向的是原生的实现
        self.hook_viewWillAppear(animated)
    }
}

// MARK: - 2. 演示页面
class MethodSwizzlingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Method Swizzling Demo"
        
        setupUI()
        
        // 触发交换 (实际项目中通常在 AppDelegate 的 didFinishLaunching 中触发)
        UIViewController.swizzleViewWillAppear
    }
    
    func setupUI() {
        let label = UILabel()
        label.text = "请查看控制台输出\n每次页面显示都会触发 Hook 日志"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        let btn = UIButton(type: .system)
        btn.setTitle("跳转测试 (Push)", for: .normal)
        btn.addTarget(self, action: #selector(pushTest), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func pushTest() {
        let testVC = UIViewController()
        testVC.view.backgroundColor = .systemBlue
        testVC.title = "测试页面"
        navigationController?.pushViewController(testVC, animated: true)
    }
}
