//
//  SegmentedViewUseViewController.swift
//  falcon
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

extension SegmentedViewUseViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return dataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> any JXSegmentedListContainerViewListDelegate {
        let listVC = SegmentedListViewController()
        listVC.category = categories[index]
        return listVC
    }
    
    func scrollViewClass(in listContainerView: JXSegmentedListContainerView) -> AnyClass {
        return MDScrollView.self
    }
}

extension SegmentedViewUseViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        // Handle selection if needed
    }
}

// MARK: - List Content Controller
class SegmentedListViewController: UIViewController, JXSegmentedListContainerViewListDelegate {
    
    var category: String = ""
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = DSColor.backgroundSecondary // 浅灰色背景，突出卡片
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        tv.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.safeAreaBottom + DSSpacing.m, right: 0)
        return tv
    }()
    
    private var items: [(title: String, subtitle: String, icon: String)] = []

    func listView() -> UIView {
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        md_hideNavigationBar = true
        view.backgroundColor = DSColor.backgroundSecondary
        setupData()
        setupUI()
        setupHeader()
    }
    
    private func setupHeader() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        let banner = DSBannerView(style: .info, title: "\(category) 频道", message: "汇集全网优质 \(category) 内容，每日更新。", showCloseButton: false)
        
        headerContainer.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: DSSpacing.s, left: DSSpacing.m, bottom: DSSpacing.s, right: DSSpacing.m))
        }
        
        // Layout immediately to calculate height if needed, but here fixed height is okay for demo
        headerContainer.layoutIfNeeded()
        
        // Dynamic height calculation based on banner content
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = headerContainer.systemLayoutSizeFitting(targetSize).height
        headerContainer.frame.size.height = height
        
        tableView.tableHeaderView = headerContainer
    }
    
    private func setupData() {
        // 根据 category 生成模拟数据
        for i in 1...10 {
            items.append((
                title: "\(category) - 内容标题 \(i)",
                subtitle: "这是一个基于 Design System 构建的列表项演示，展示了 \(category) 的详细描述信息。",
                icon: getIconName()
            ))
        }
    }
    
    private func getIconName() -> String {
        let icons = ["star.fill", "heart.fill", "bookmark.fill", "bell.fill", "flag.fill", "bolt.fill"]
        return icons.randomElement() ?? "star.fill"
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SegmentedListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as? DSCardListCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle, iconName: item.icon)
        
        // 使用白色卡片背景，与灰色列表背景形成对比
        cell.cardContainer.backgroundColor = DSColor.backgroundPrimary
        // 增加阴影，提升层次感
        cell.elevation = .low
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 模拟点击效果
        let item = items[indexPath.row]
        print("Selected: \(item.title)")
    }
}
