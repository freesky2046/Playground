//
//  UseNavigationBarController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/10.
//

import Foundation
import UIKit

class UseNavigationBarController: UIViewController, UIGestureRecognizerDelegate { // 1. 加上协议
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // MARK: - ⚠️ iOS 13- 已废弃 (Old API)
        
        // black: 把状态栏时间/电量变成 白色
        // default: 把状态栏时间/电量变成 黑色
        navigationController?.navigationBar.barStyle = .black
        // 用于导航栏的背景色
        navigationController?.navigationBar.barTintColor = .black
        // 透视开关 半透明效果, 是否和底部的视图融合
        navigationController?.navigationBar.isTranslucent = true
        // 旧版标题颜色
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.blue]
        // 旧版返回按钮图标
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "img")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "img")
       
        // MARK: - ✅ 新 API (Appearance) - 推荐
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground() // 使用默认毛玻璃效果
        
        // 1. 改全局标题文字样式
        appearance.titleTextAttributes = [.foregroundColor : UIColor.red]

        // 2. 背景设置
        // appearance.backgroundEffect = nil // 1. 去掉毛玻璃
        appearance.backgroundColor = .white  // 2. 背景色
        appearance.shadowColor = .clear      // 3. 去掉底下的分割线 (阴影)
        
        // MARK: - ✅ 补全2: 新版 Appearance 的高级配置
        // 2.1 修改返回箭头图标
        // let backImg = UIImage(named: "back_arrow")
        // appearance.setBackIndicatorImage(backImg, transitionMaskImage: backImg)
        
        // 2.2 调整返回文字位置 (比如隐藏文字)
        // appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -200, vertical: 0)

        // 应用 Appearance
        navigationController?.navigationBar.standardAppearance = appearance
        
        // MARK: - ✅ 补全1: 适配 iOS 15+ 滚动边缘
        // 如果不加这句，列表滚到顶部时导航栏会变透明
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        
        // MARK: - ⚠️ 新老系统通用配置
        // 1. 改标题内容
        // 方式1: 全局标题
        self.title = "123"
        
        // 方式2: 局部自定义 TitleView
        let label = UILabel(frame: CGRectMake(0, 0, 100, 40))
        label.text = "标题"
        label.textAlignment = .center
        label.textColor = .black
        self.navigationItem.titleView = label
        
        // 2. 按钮颜色 (包括返回按钮的图标+文字颜色)
        navigationController?.navigationBar.tintColor = UIColor.brown
        
        // 3. 返回按钮的内容
        // 方式1: 要设置当前返回, 就得在上一个设置 (PreVC), 不太常用
        // 见 BasicKnowledgeViewController
        // navigationItem.backBarButtonItem = UIBarButtonItem(title: "回回", style: .plain, target: nil, action: nil)
        
        // 方式2: 直接设置 leftBarButtonItem, 会覆盖 backBarButtonItem
        // 代价就是自己得加 action, 且侧滑手势会失效
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "BBB", style: .plain, target: self, action: #selector(pop))
        
        // MARK: - ✅ 补全3: 解决自定义返回按钮的手势失效问题
        // 当你使用了 leftBarButtonItem，必须加上这句，否则侧滑返回会失效
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // MARK: - ✅ 补全4: 右侧按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - ✅ 补全6: 导航栏隐藏与显示 (核心坑点)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. 隐藏导航栏
        // 建议在 viewWillAppear 里设置，离开时(viewWillDisappear)还原
        // animated: true 很重要，否则切换会有突兀感
        // self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 2. 还原导航栏 (必做！否则会影响下一个页面)
        // self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    // 补全3的配套代理方法
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果是根控制器，就不响应侧滑（防止卡死）
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    // MARK: - ✅ 补全5: 状态栏颜色 (最推荐的写法)
    // 现在的最佳实践：不要依赖 barStyle，直接告诉系统你要啥颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .darkContent
    }
}
