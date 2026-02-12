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
class JXPagingNestedSegmentViewController: UIViewController {
    
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
    
    }
}

extension JXPagingNestedSegmentViewController: JXPagingViewDelegate {
    
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
        let list = PagingListViewController()
        list.category = categories[index]
        return list
    }
    
    func scrollViewClassInListContainerView(in pagingView: JXPagingView) -> AnyClass? {
        MDScrollView.self
    }
}

