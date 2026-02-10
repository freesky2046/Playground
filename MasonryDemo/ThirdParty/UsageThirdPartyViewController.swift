//
//  HomeViewController.swift
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
    var dataList: [String] = [
        "ZLPhotoBrowser", // 相册选择
        "segmentView", // 分页
        "pagingView"   // 悬停
       
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
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(UIWindow.safeAreaInsets.top)
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复导航栏
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }

}

extension UsageThirdPartyViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
           // Only allow swiping if there's a page to go back to
           return (navigationController?.viewControllers.count ?? 0) > 1
       }
}
                                            
  

extension UsageThirdPartyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = dataList[indexPath.row]
        
        switch title {
        case "ZLPhotoBrowser":
            let photoBrower = PhotoBrowerViewController()
            navigationController?.pushViewController(photoBrower, animated: true)
        case "segmentView":
            let segmentView = SegmentedViewUseViewController()
            navigationController?.pushViewController(segmentView, animated: true)
        case "pagingView":
            let pagingview = JXPagingViewUseViewController()
            navigationController?.pushViewController(pagingview, animated: true)
        default:
            break
        }
    }
}

extension UsageThirdPartyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
