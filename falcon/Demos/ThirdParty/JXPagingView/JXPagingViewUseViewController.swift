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

// 让 JXPagingListContainerView 遵从 JXSegmentedViewListContainer 协议
extension JXPagingListContainerView: @retroactive JXSegmentedViewListContainer {}

// MARK: - Header View
class PagingHeaderView: UIView {
    
    private let avatar = DSAvatar(size: .large, text: "M", image: nil)
    private let nameLabel = DSLabel(style: .h2)
    private let bioLabel = DSLabel(style: .body)
    private let statsStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DSColor.backgroundPrimary
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.xl)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.text = "Design System User"
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
        }
        
        bioLabel.text = "热爱编程，热爱设计。\n正在使用 JXPagingView 展示个人主页效果。"
        bioLabel.textAlignment = .center
        bioLabel.textColor = DSColor.textSecondary
        bioLabel.numberOfLines = 0
        addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(DSSpacing.s)
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        // Stats
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = DSSpacing.m
        
        let stats = [("文章", "128"), ("关注", "342"), ("粉丝", "1.2k")]
        for (label, value) in stats {
            let v = createStatView(label: label, value: value)
            statsStack.addArrangedSubview(v)
        }
        
        addSubview(statsStack)
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(DSSpacing.l)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
    }
    
    private func createStatView(label: String, value: String) -> UIView {
        let v = UIView()
        let valL = DSLabel(style: .h3)
        valL.text = value
        valL.textAlignment = .center
        
        let keyL = DSLabel(style: .caption)
        keyL.text = label
        keyL.textAlignment = .center
        keyL.textColor = DSColor.textSecondary
        
        v.addSubview(valL)
        v.addSubview(keyL)
        
        valL.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        keyL.snp.makeConstraints { make in
            make.top.equalTo(valL.snp.bottom).offset(DSSpacing.xxs)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return v
    }
}

// MARK: - Main Controller
class JXPagingViewUseViewController: UIViewController {
    
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
        
        // Fix for safe area when nav bar is hidden? 
        // If md_hideNavigationBar is true, we usually want content to go under status bar or start below it.
        // Here we start below status bar for simplicity.
    }
}

extension JXPagingViewUseViewController: JXPagingViewDelegate {
    
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

// MARK: - List Controller
class PagingListViewController: UIViewController, JXPagingViewListViewDelegate {
    
    var category: String = ""
    var scrollCallback: ((UIScrollView) -> ())?
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = DSColor.backgroundSecondary
        t.separatorStyle = .none
        if #available(iOS 15.0, *) {
            t.sectionHeaderTopPadding = 0.0
        }
        t.delegate = self
        t.dataSource = self
        t.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        t.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.safeAreaBottom + DSSpacing.m, right: 0)
        return t
    }()
    
    private var items: [(title: String, subtitle: String, icon: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundSecondary
        setupData()
        setupUI()
    }
    
    private func setupData() {
        for i in 1...15 {
            items.append((
                title: "\(category) - 项目 \(i)",
                subtitle: "这是 \(category) 下的一个详细条目，展示了 JXPagingView 与 Design System 的完美结合。",
                icon: ["doc.text.fill", "bookmark.fill", "heart.fill", "star.fill"].randomElement()!
            ))
        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - JXPagingViewListViewDelegate
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

extension PagingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as? DSCardListCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle, iconName: item.icon)
        
        // Style update
        cell.cardContainer.backgroundColor = DSColor.backgroundPrimary
        cell.elevation = .low
        
        return cell
    }
}


