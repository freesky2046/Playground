//
//  UsageThirdPartyViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

extension UsageThirdPartyViewController: RouteCompatible {
    
}

class UsageThirdPartyViewController: UIViewController {
    
    struct ItemModel {
        let title: String
        let subtitle: String
        let icon: String
        let actionKey: String
    }
    
    lazy var dataList: [ItemModel] = [
        ItemModel(title: "ZLPhotoBrowser", subtitle: "高性能图片/视频选择框架", icon: "photo.on.rectangle.angled", actionKey: "ZLPhotoBrowser"),
        ItemModel(title: "Segment View", subtitle: "JXSegmentedView 分页控制组件", icon: "square.split.3x1.fill", actionKey: "segmentView"),
        ItemModel(title: "Paging View", subtitle: "JXPagingView 悬停列表组件", icon: "arrow.up.and.down.circle.fill", actionKey: "pagingView"),
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

extension UsageThirdPartyViewController: UITableViewDataSource, UITableViewDelegate {
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
        case "ZLPhotoBrowser":
            let photoBrower = PhotoBrowerViewController()
            navigationController?.pushViewController(photoBrower, animated: true)
        case "segmentView":
            let segmentView = SegmentedViewUseViewController()
            navigationController?.pushViewController(segmentView, animated: true)
        case "pagingView":
            let pagingview = JXPagingViewUseViewController()
            navigationController?.pushViewController(pagingview, animated: true)
        case "DZNEmptyDataSet":
            let usage = DZNEmptyDataSetUsageViewController()
            navigationController?.pushViewController(usage, animated: true)
        default:
            break
        }
    }
}
