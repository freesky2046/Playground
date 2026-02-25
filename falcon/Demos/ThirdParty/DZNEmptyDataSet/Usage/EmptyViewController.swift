//
//  UsageThirdPartyViewController.swift
//  falcon
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit


class EmptyViewController: UIViewController {
    
    struct ItemModel {
        let title: String
        let subtitle: String
        let icon: String
        let actionKey: String
    }
    
    lazy var dataList: [ItemModel] = [
        ItemModel(title: "MDEmptyView", subtitle: "📦", icon: "photo.on.rectangle.angled", actionKey: "MDEmptyView"),
        ItemModel(title: "Empty Data Set", subtitle: "DZNEmptyDataSet 空状态管理", icon: "square.dashed", actionKey: "DZNEmptyDataSet")
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = DSColor.backgroundPrimary
        tableView.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.m, right: 0)
        tableView.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Third Party"
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

extension EmptyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as! DSCardListCell
        let item = dataList[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle, iconName: item.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataList[indexPath.row]
        
        switch item.actionKey {
        case "MDEmptyView":
            let photoBrower = CustomEmptyViewController()
            navigationController?.pushViewController(photoBrower, animated: true)
        case "DZNEmptyDataSet":
            let usage = DZNEmptyDataSetUsageViewController()
            navigationController?.pushViewController(usage, animated: true)
        default:
            break
        }
    }
}
