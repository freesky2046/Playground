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
    var dataList: [String] = [
        "YYText",
        "Alamofire",
        "Router",
        "ThirdParty",
        "Namespace",
        "UIKitExtension",
        "YYCache",
        "BaiscKnowledge",
        "Kingfisher",
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "列表"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(100.0)
        }
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = dataList[indexPath.row]
        
        switch title {
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
            let basic = BasicKnowledgeViewController()
            navigationController?.pushViewController(basic, animated: true)
        case "Kingfisher":
            let kingfisher = KingfisherViewController()
            navigationController?.pushViewController(kingfisher, animated: true)
//        case "FigmaDesign":
//            let figma = FigmaDesignViewController()
//            navigationController?.pushViewController(figma, animated: true)
        case "ThirdParty":
            try? SimpleRouter.shared.route(url: "md://thirdParty")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
