//
//  MDTabbarController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/11.
//

import UIKit

class MDTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewControllers()
        setupAppearance()
    }
    
    private func setupChildViewControllers() {
        // 1. 列表 (List) -> 使用 "list.bullet.rectangle" 系列
        // 隐喻：结构化的数据展示
        let homeVC = HomeViewController()
        setupChild(homeVC, 
                  title: "列表", 
                  imageName: "list.bullet.rectangle.portrait", 
                  selectedImageName: "list.bullet.rectangle.portrait.fill")
        
        // 2. 基础 (Basic) -> 使用 "text.book.closed" 系列
        // 隐喻：知识库、文档、学习资料
        let basicVC = BasicKnowledgeViewController()
        setupChild(basicVC, 
                  title: "基础", 
                  imageName: "text.book.closed", 
                  selectedImageName: "text.book.closed.fill")
        
        // 3. 设计 (Design) -> 使用 "swatchpalette" 系列
        // 隐喻：调色盘、设计系统、创意工具
        let designVC = DesignSystemDemoViewController()
        setupChild(designVC, 
                  title: "设计", 
                  imageName: "swatchpalette", 
                  selectedImageName: "swatchpalette.fill")
        
        self.viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: basicVC),
            UINavigationController(rootViewController: designVC)
        ]
    }
    
    private func setupChild(_ vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        vc.title = title
        // 本身内容还是靠tabbarItem
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = UIImage(systemName: selectedImageName)?.withRenderingMode(.alwaysOriginal)
    }
    
    private func setupAppearance() {
        // TabBar Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = DSColor.tabBarBackground // 使用 Design System 背景色
        
        // 使用 Design System 配置 Item 颜色
        let itemAppearance = appearance.stackedLayoutAppearance
        
        // 选中状态 (Brand Color - 活力黄)
        itemAppearance.selected.iconColor = DSColor.tabBarSelected
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: DSColor.tabBarSelected,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // 未选中状态 (Gray)
        itemAppearance.normal.iconColor = DSColor.tabBarUnselected
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: DSColor.tabBarUnselected,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        // 同步到 inline/compact 模式
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        // 兜底设置
        tabBar.tintColor = DSColor.tabBarSelected
    }

}
