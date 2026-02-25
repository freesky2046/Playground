//
//  JXPagingViewUseViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit
import JXPagingView
import JXSegmentedView
import SnapKit



// MARK: - Main Controller
class JXPagingNestCategoryViewController: UIViewController {
    
    private let headerHeight: Int = 260
    private let sectionHeaderHeight: Int = 50
    
    lazy var userHeaderView: PagingHeaderView = PagingHeaderView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: headerHeight))
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(sectionHeaderHeight)))
    lazy var dataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    lazy var pagingView: JXPagingView = JXPagingView(delegate: self, listContainerType: .scrollView)
    let categories = ["个人动态", "收藏文章", "关注话题"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        // 隐藏导航栏以展示全屏效果
        self.md_hideNavigationBar = true
        
        setupSegmentedView()
        setupPagingView()
    }
    
    private func setupSegmentedView() {
        dataSource.titles = categories
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titleNormalColor = DSColor.textSecondary
        dataSource.titleSelectedColor = DSColor.brand
        dataSource.titleNormalFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        dataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        dataSource.isItemSpacingAverageEnabled = false
        dataSource.itemSpacing = DSSpacing.l
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorColor = DSColor.brand
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 4
        
        segmentedView.dataSource = dataSource
        segmentedView.indicators = [indicator]
        segmentedView.backgroundColor = DSColor.backgroundPrimary
        
        // Bottom separator
        let line = UIView()
        line.backgroundColor = DSColor.separator
        segmentedView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setupPagingView() {
        view.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.safeAreaTop) // Consider safe area if hiding nav bar
            make.left.bottom.right.equalToSuperview()
        }
        
        // Link list container
        segmentedView.listContainer = pagingView.listContainerView
        
        //
        pagingView.mainTableView.backgroundColor = .red
        pagingView.mainTableView.gestureDelegate = self
        
        // Fix for safe area when nav bar is hidden?
        // If md_hideNavigationBar is true, we usually want content to go under status bar or start below it.
        // Here we start below status bar for simplicity.
    }
}

extension JXPagingNestCategoryViewController: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }

        if otherGestureRecognizer == self.navigationController?.md_FullscreenPopGestureRecognizer {
            return false
        }
        
        
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}



extension JXPagingNestCategoryViewController: JXPagingViewDelegate {
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return headerHeight
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return userHeaderView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return sectionHeaderHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return categories.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> any JXPagingViewListViewDelegate {
        let list = ListViewController()

        return list
    }
    
    func scrollViewClassInListContainerView(in pagingView: JXPagingView) -> AnyClass? {
        MDScrollView.self
    }
}


extension ListViewController: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return view
    }
    
    func listScrollView() -> UIScrollView {
        currentView ?? UIScrollView()
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        scrollCallback = callback
    }
    
}


class ListViewController: UIViewController  {
    var scrollCallback: ((UIScrollView) -> Void)?
    var currentView: UIScrollView?
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: .zero)
    lazy var dataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    lazy var listContainer: JXSegmentedListContainerView = JXSegmentedListContainerView(dataSource: self)
    
    // 模拟数据源
    let categories = ["热门推荐", "最新动态", "技术干货", "设计灵感"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        title = "Segmented View"
        
        setupNavigationBar()
        setupSegmentedView()
        setupLayout()
    }
    
    private func setupNavigationBar() {
        // 恢复默认导航栏样式，保持统一
        md_hideNavigationBar = true
//        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupSegmentedView() {
        // 1. 配置数据源
        dataSource.titles = categories
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titleNormalColor = DSColor.textSecondary
        dataSource.titleSelectedColor = DSColor.brand
        dataSource.titleNormalFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        dataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        dataSource.isItemSpacingAverageEnabled = false
        dataSource.itemSpacing = DSSpacing.l
        
        // 2. 配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorColor = DSColor.brand
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 4 // 稍微向下一点，贴近底部
        
        segmentedView.indicators = [indicator]
        segmentedView.dataSource = dataSource
        segmentedView.delegate = self
        segmentedView.listContainer = listContainer
        
        // 3. 视觉配置
        segmentedView.backgroundColor = DSColor.backgroundPrimary
        
        // 添加底部分割线
        let separatorLine = UIView()
        separatorLine.backgroundColor = DSColor.backgroundSecondary
        segmentedView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setupLayout() {
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44.0)
        }
        
        view.addSubview(listContainer)
        listContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension ListViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return dataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> any JXSegmentedListContainerViewListDelegate {
        let listVC = SegmentedListViewController()
        listVC.category = categories[index]
        listVC.scrollCallback = { scrollView in
            self.scrollCallback?(scrollView)
        }
        self.currentView = listVC.tableView
        return listVC
    }
    
    func scrollViewClass(in listContainerView: JXSegmentedListContainerView) -> AnyClass {
        return MDScrollView.self
    }
}

extension ListViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        let viewcontroller =  listContainer.validListDict[index] as! SegmentedListViewController
        self.currentView =  viewcontroller.tableView
        // Handle selection if needed
    }
}

