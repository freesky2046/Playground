//
//  HomeViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

extension HomeViewController: RouteCompatible {
    
}

class HomeViewController: UIViewController {
    
    // 数据模型结构体
    struct ItemModel {
        let title: String
        let subtitle: String
        let icon: String
        let actionKey: String
    }
    
    var dataList: [ItemModel] = [
        ItemModel(title: "Basic Knowledge", subtitle: "队列、锁、运行时、Timer 等基础知识", icon: "book.closed.fill", actionKey: "BaiscKnowledge"),
        ItemModel(title: "UIKit Extension", subtitle: "常用 UI 控件封装与扩展", icon: "paintbrush.fill", actionKey: "UIKitExtension"),
        ItemModel(title: "Design System", subtitle: "Design Tokens & Components", icon: "swatchpalette.fill", actionKey: "DesignSystem"), // 新增入口
        ItemModel(title: "YYText", subtitle: "富文本布局与渲染", icon: "text.alignleft", actionKey: "YYText"),
        ItemModel(title: "Alamofire", subtitle: "网络请求封装与使用", icon: "network", actionKey: "Alamofire"),
        ItemModel(title: "Kingfisher", subtitle: "图片加载与缓存策略", icon: "photo.stack", actionKey: "Kingfisher"),
        ItemModel(title: "Router", subtitle: "组件化路由跳转方案", icon: "arrow.triangle.branch", actionKey: "Router"),
        ItemModel(title: "YYCache", subtitle: "高性能缓存框架分析", icon: "internaldrive.fill", actionKey: "YYCache"),
        ItemModel(title: "Third Party", subtitle: "其他第三方库集成示例", icon: "square.grid.2x2.fill", actionKey: "ThirdParty"),
        ItemModel(title: "Namespace", subtitle: "命名空间封装技巧", icon: "curlybraces", actionKey: "Namespace"),
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
        self.title = "Home"
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

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0 // 卡片高度
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataList[indexPath.row]
        
        switch item.actionKey {
        case "YYText":
            let yytext = YYTextController()
            navigationController?.pushViewController(yytext, animated: true)
        case "Alamofire":
            let alamofire = AlamofireViewController()
            navigationController?.pushViewController(alamofire, animated: true)
        case "Router":
            let router = RouterViewController()
            navigationController?.pushViewController(router, animated: true)
        case "UIKitExtension":
            let kit = UIKitViewController()
            navigationController?.pushViewController(kit, animated: true)
        case "YYCache":
            let cache = CacheViewController()
            navigationController?.pushViewController(cache, animated: true)
        case "BaiscKnowledge":
            // 这里我们希望 BasicKnowledge 作为一个 Tab 存在，如果从这里点进去可能希望是 Push 进去看详情
            // 或者跳转到 TabBar 的第二个 Item
            if let tabBar = self.tabBarController {
                tabBar.selectedIndex = 1
            }
        case "Kingfisher":
            let kingfisher = KingfisherViewController()
            navigationController?.pushViewController(kingfisher, animated: true)
        case "ThirdParty":
            try? SimpleRouter.shared.route(url: "md://thirdParty")
        case "DesignSystem":
             if let tabBar = self.tabBarController {
                 tabBar.selectedIndex = 2
             }
        default:
            break
        }
    }
}



extension HomeViewController: UITableViewDataSource {
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
