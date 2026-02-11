//
//  TabbarAppearanceDemoViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

class TabbarAppearanceDemoViewController: UIViewController {
    
    // 这个 appearance 是我们的“草稿”，修改它不会直接影响 UI，直到我们赋值给 tabBar
    private let appearance = UITabBarAppearance()
    
    // 保存进入页面之前的原始样式，用于退出时还原
    private var originalStandardAppearance: UITabBarAppearance?
    private var originalScrollEdgeAppearance: UITabBarAppearance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        title = "UITabBarAppearance Lab"
        setupUI()
        // 2. 应用初始 Demo 样式
        configureOpaque()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 3. 页面退出时还原，避免污染全局 TabBar
        restoreOriginalAppearance()
    }
    

    
    private func restoreOriginalAppearance() {
        guard let tabBar = tabBarController?.tabBar else { return }
        if let original = originalStandardAppearance {
            tabBar.standardAppearance = original
        }
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = originalScrollEdgeAppearance
        }
    }
    
    // MARK: - UI Elements
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        view.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        let label = UILabel()
        label.text = "点击下方按钮实时修改 TabBar 样式"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        stack.addArrangedSubview(label)
        
        stack.addArrangedSubview(createButton(title: "1. 默认不透明 (Opaque)", action: #selector(configureOpaque)))
        stack.addArrangedSubview(createButton(title: "2. 完全透明 (Transparent)", action: #selector(configureTransparent)))
        stack.addArrangedSubview(createButton(title: "3. 磨砂效果 (Blur Effect)", action: #selector(configureBlur)))
        stack.addArrangedSubview(createButton(title: "4. 自定义背景色 (Custom Color)", action: #selector(configureCustomColor)))
        stack.addArrangedSubview(createButton(title: "5. 自定义 Item 样式", action: #selector(configureItemAppearance)))
        stack.addArrangedSubview(createButton(title: "重置 (Reset)", action: #selector(resetAppearance)))
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    // MARK: - Actions
    
    @objc private func updateTabBar() {
        // iOS 13+ 必须同时设置 standardAppearance 和 scrollEdgeAppearance
        tabBarController?.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    /// 1. 默认不透明背景 (最常用)
    /// 适用于：大多数标准 App，底色通常是白色或黑色
    @objc private func configureOpaque() {
        appearance.configureWithOpaqueBackground()
        // 可以在此基础上微调
        // 1.背景色
        appearance.backgroundColor = .white // 确保是纯色
        
        // 2.icon颜色
        appearance.stackedLayoutAppearance.selected.iconColor = DSColor.tabBarSelected
        appearance.stackedLayoutAppearance.normal.iconColor = DSColor.tabBarUnselected
        
        // 3.文字
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor:  DSColor.tabBarSelected]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor:  DSColor.tabBarUnselected]

        updateTabBar()
    }
    
    /// 2. 完全透明背景
    /// 适用于：地图类应用、全屏展示类应用
    /// 注意：内容会透到底部，需要处理好底部遮挡
    @objc private func configureTransparent() {
        appearance.configureWithTransparentBackground()
        
        // 去掉分割线（阴影线）
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        
        updateTabBar()
    }
    
    /// 3. 磨砂/毛玻璃效果 (Default)
    /// 适用于：iOS 系统原生风格
    @objc private func configureBlur() {
        appearance.configureWithDefaultBackground()
        // 系统默认就是带 Blur 的
        updateTabBar()
    }
    
    /// 4. 自定义背景色和图片
    @objc private func configureCustomColor() {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.2)
        
        // 设置顶部黑线颜色
        appearance.shadowColor = .red
        
        // 甚至可以设置背景图
        // appearance.backgroundImage = UIImage(named: "texture")
        
        updateTabBar()
    }
    
    /// 5. 深度定制 Item (图标和文字)
    @objc private func configureItemAppearance() {
        // stackedLayoutAppearance: 正常的图文垂直排列模式
        let itemAppearance = appearance.stackedLayoutAppearance
        
        // 选中状态
        itemAppearance.selected.iconColor = .systemPurple
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        
        // 未选中状态
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        
        // Badge 样式 (小红点)
        itemAppearance.normal.badgeBackgroundColor = .systemRed
        itemAppearance.normal.badgeTextAttributes = [.foregroundColor: UIColor.white]
        
        // 同步到其他模式 (横屏时可能用到 inline 或 compact)
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        updateTabBar()
        
        // 给当前 Tab 加个 Badge 看看效果
        navigationController?.tabBarItem.badgeValue = "99"
        // 小红点
        navigationController?.tabBarItem.badgeValue = ""
    }
    
    @objc private func resetAppearance() {
        let newAppearance = UITabBarAppearance()
        newAppearance.configureWithDefaultBackground()
        newAppearance.backgroundColor = .systemBackground
        
        tabBarController?.tabBar.standardAppearance = newAppearance
        if #available(iOS 15.0, *) {
            tabBarController?.tabBar.scrollEdgeAppearance = newAppearance
        }
        tabBarController?.tabBar.tintColor = .systemBlue
        navigationController?.tabBarItem.badgeValue = nil
        
        // Reset local reference
        self.appearance.configureWithDefaultBackground()
    }
}
