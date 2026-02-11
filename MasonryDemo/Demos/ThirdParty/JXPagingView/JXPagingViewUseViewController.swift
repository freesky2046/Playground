//
//  JXPagingViewUseViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit
import JXPagingView
import JXSegmentedView
import SnapKit

// 让 JXPagingListContainerView 遵从 JXSegmentedViewListContainer 协议
extension JXPagingListContainerView: @retroactive JXSegmentedViewListContainer {}

class HeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randomColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JXPagingViewUseViewController: UIViewController {
    lazy var userHeaderView: HeaderView = HeaderView()
    let dataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(pinSectionHeaderHeight)))
    lazy var pagingView: JXPagingView = JXPagingView(delegate: self, listContainerType: .scrollView)
    
    var titles = ["能力", "爱好", "队友"]
    var pinSectionHeaderHeight: Int = 44
    var userHeaderViewHeight: Int = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.md_hideNavigationBar = true
        dataSource.titles = titles
        dataSource.isItemSpacingAverageEnabled = false
        segmentedView.dataSource = dataSource
        
        view.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIWindow.safeAreaInsets.top)
            make.left.bottom.right.equalToSuperview()
        }
        // 很重要,先要让 JXPagingListContainerView 遵从JXSegmentedViewListContainer协议
        segmentedView.listContainer = pagingView.listContainerView
        pagingView.reloadData()
    }
}

extension JXPagingViewUseViewController: JXPagingViewDelegate {
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> any JXPagingViewListViewDelegate {
        let list = PagingListViewController()
        return list
    }
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        userHeaderViewHeight
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return userHeaderView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        pinSectionHeaderHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        titles.count
    }
}

class PagingListViewController: UIViewController, JXPagingViewListViewDelegate {
   
    /// 滑动的时候告知外部(即JXPagingView 自己的scrollView是什么,方便联动悬停)
    var scrollCallback:((UIScrollView) -> ())?
    
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.delegate = self
        if #available(iOS 15.0, *) {
            t.sectionHeaderTopPadding = 0.0
        }
        t.dataSource = self
        t.separatorStyle = .none
        t.contentInsetAdjustmentBehavior = .never
        t.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func listScrollView() -> UIScrollView {
        return tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        scrollCallback = callback
    }
    
    func listView() -> UIView {
        return self.view
    }
    
}

extension PagingListViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
}

extension PagingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}


