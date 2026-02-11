//
//  HomeViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

extension BasicKnowledgeViewController: RouteCompatible {
    static func customNavigation(params: [String : String]) -> Bool {
          if UserDefaults.standard.bool(forKey: "isLogin") == false {
              return false
          }
          return false
      }
      
      func handleParams(params: [String : String]) {
          param = Int(params["p"] ?? "") ?? 0
      }
}


class BasicKnowledgeViewController: UIViewController {
    
    // 数据模型结构体
    struct ItemModel {
        let title: String
        let subtitle: String
        let icon: String
        let actionKey: String
    }
    
    var param: Int = 0
    
    var dataList: [ItemModel] = [
        ItemModel(title: "Queue", subtitle: "GCD 队列与多线程基础", icon: "tray.full.fill", actionKey: "Queue"),
        ItemModel(title: "Lock", subtitle: "iOS 中的各种锁与性能对比", icon: "lock.fill", actionKey: "Lock"),
        ItemModel(title: "Timer", subtitle: "NSTimer, GCD Timer 使用与注意事项", icon: "timer", actionKey: "Timer"),
        ItemModel(title: "Associated Object", subtitle: "Runtime 关联对象原理解析", icon: "link", actionKey: "AssociatedObject"),
        ItemModel(title: "Navigation", subtitle: "导航栏样式定制与交互", icon: "compass.drawing", actionKey: "Navigation"),
        ItemModel(title: "TabBar Appearance", subtitle: "TabBar 样式深度定制指南", icon: "menubar.dock.rectangle", actionKey: "TabBarAppearance"),
        ItemModel(title: "Design System", subtitle: "Banner, Card, Tokens 等组件展示", icon: "paintbrush.fill", actionKey: "DesignSystem")
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // 去掉原生分割线
        tableView.backgroundColor = DSColor.backgroundPrimary
        tableView.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.m, right: 0)
        tableView.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Basic Knowledge"
        view.backgroundColor = DSColor.backgroundPrimary
        
        // 导航栏大标题风格
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension BasicKnowledgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0 // 卡片高度
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataList[indexPath.row]
        // 这里的 title 可能是 actionKey，或者我们需要用 item.actionKey 来判断
        // 原来的逻辑是基于 title 字符串判断的，现在用 actionKey 更稳健
        
        switch item.actionKey {
        case "Queue":
            let queue = QueueViewController()
            navigationController?.pushViewController(queue, animated: true)
        case "Lock":
            break
        case "Timer":
            let timer = UsageTimerViewController()
            navigationController?.pushViewController(timer, animated: true)
        case "AssociatedObject":
            let associatedObject = AssociatedObjectViewController()
            navigationController?.pushViewController(associatedObject, animated: true)
        case "Navigation":
            let controller: UseNavigationBarController = UseNavigationBarController()
            navigationController?.pushViewController(controller, animated: true)
        case "TabBarAppearance":
            let vc = TabbarAppearanceDemoViewController()
            vc.md_tabBarAutoHideDisable = true // 禁用自动隐藏，因为这个页面需要展示 TabBar 效果
            vc.hidesBottomBarWhenPushed = false
            navigationController?.pushViewController(vc, animated: true)
        case "DesignSystem":
            let vc = DesignSystemDemoViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension BasicKnowledgeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as! DSCardListCell
        let item = dataList[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle, iconName: item.icon)
        return cell
    }
}
