//
//  SegmentedViewUseViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit
import JXSegmentedView
import SnapKit

// https://github.com/pujiaxin33/JXSegmentedView

class SegmentedViewUseViewController: UIViewController  {
   
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: .zero)
    lazy var dataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    lazy var listContainer: JXSegmentedListContainerView = JXSegmentedListContainerView(dataSource: self)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复导航栏
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // 使用 UINavigationBarAppearance 设置导航栏外观（iOS 13+ 推荐）
        let appearance = UINavigationBarAppearance()
        // 设置导航栏背景色
        appearance.backgroundColor = .clear

        // 设置导航栏标题颜色
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red
        ]
        // 应用外观配置
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance  // 滚动时的外观
        self.navigationController?.navigationBar.compactAppearance = appearance     // 横屏紧凑模式的外观
        
        dataSource.titles = ["1", "2", "3"]
        dataSource.isItemSpacingAverageEnabled = false
        dataSource.itemSpacing = 10
        dataSource.itemWidth = 40.0
        dataSource.itemWidthIncrement = 20.0
        segmentedView.contentEdgeInsetLeft = 20.0
        segmentedView.backgroundColor = UIColor.white
        segmentedView.dataSource = self.dataSource
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIWindow.safeAreaInsets.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44.0)
        }
        segmentedView.listContainer = listContainer
        
        view.addSubview(listContainer)
        listContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        segmentedView.reloadData()

    }
   
}

extension SegmentedViewUseViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return dataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> any JXSegmentedListContainerViewListDelegate {
        let list = ListViewController()
        return list
    }
}

class ListViewController: UIViewController, JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
    }
}
