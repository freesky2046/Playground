//
//  MDTabbarController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/11.
//

import UIKit
import ESTabBarController_swift

class MDESTabBarController: ESTabBarController {

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
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        vc.tabBarItem.selectedImage = UIImage(systemName: selectedImageName)
    }
    
    
    func setupAppearance() {
        // 不生效
        tabBar.standardAppearance.backgroundColor = .brown
        // 生效
        tabBar.barTintColor = .red
    }



}
