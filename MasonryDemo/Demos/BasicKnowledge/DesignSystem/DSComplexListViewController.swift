//
//  DSComplexListViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

// MARK: - Data Models
enum FeedContentType {
    case banner(DSBannerView.Style, String)
    case image(String, String, String) // ImageName, Title, Subtitle
    case interactive // TextField + Button
    case loading
    case empty
    case mixed // Tags + Banner
}

struct FeedItem {
    let avatarName: String? // nil for initials
    let name: String
    let time: String
    let content: String
    let type: FeedContentType
    let tags: [String]
}

// MARK: - Complex Cell
class DSComplexFeedCell: UITableViewCell {
    
    static let identifier = "DSComplexFeedCell"
    
    // MARK: - UI Components
    private lazy var cardView: DSCardView = {
        let card = DSCardView()
        card.elevation = .medium // 提升阴影层级，增加立体感
        card.layer.cornerRadius = 16 // 更圆润的角
        return card
    }()
    
    private lazy var avatarView: DSAvatar = {
        let avatar = DSAvatar(size: .custom(40)) // 稍微增大头像
        return avatar
    }()
    
    private lazy var nameLabel: DSLabel = {
        let label = DSLabel(style: .h3)
        label.font = .systemFont(ofSize: 16, weight: .bold) // 加粗名字
        return label
    }()
    
    private lazy var timeLabel: DSLabel = {
        let label = DSLabel(style: .caption)
        label.textColor = DSColor.textSecondary.withAlphaComponent(0.8) // 颜色更淡一点
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(scale: .medium)
            btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        } else {
            btn.setTitle("...", for: .normal)
        }
        btn.tintColor = DSColor.textSecondary
        return btn
    }()
    
    private lazy var contentLabel: DSLabel = {
        let label = DSLabel(style: .body)
        label.numberOfLines = 0
        // 增加行间距的逻辑通常需要 AttributedString，这里暂时简化，通过布局留白增加呼吸感
        return label
    }()
    
    // Dynamic Content Container
    private lazy var dynamicContainer: UIView = {
        let v = UIView()
        v.backgroundColor = DSColor.backgroundPrimary.withAlphaComponent(0.5) // 微弱的背景区分
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var tagsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var divider: UIView = {
        let v = UIView()
        v.backgroundColor = DSColor.backgroundSecondary
        return v
    }()
    
    private lazy var actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12) // 增加卡片间距
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        let container = cardView.contentView
        
        // Header
        container.addSubview(avatarView)
        container.addSubview(nameLabel)
        container.addSubview(timeLabel)
        container.addSubview(moreButton)
        
        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20) // 增加内部边距
            make.width.height.equalTo(40) // 明确指定大小
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView).offset(2)
            make.left.equalTo(avatarView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(moreButton.snp.left).offset(-8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avatarView).offset(-2)
            make.left.equalTo(nameLabel)
        }
        
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(32) // 更大的点击区域
        }
        
        // Content Text
        container.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        // Dynamic Container
        container.addSubview(dynamicContainer)
        dynamicContainer.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        // Tags
        container.addSubview(tagsContainer)
        tagsContainer.snp.makeConstraints { make in
            make.top.equalTo(dynamicContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.height.equalTo(28) // 稍微增高
        }
        
        // Divider - 移除或改为透明间隔
        // 这里我们选择移除显式分割线，改用布局留白
        
        // Actions
        container.addSubview(actionsStack)
        actionsStack.snp.makeConstraints { make in
            make.top.equalTo(tagsContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(40) // 增高操作栏
        }
        
        setupActions()
    }
    
    private func setupActions() {
        let actions = ["Like", "Comment", "Share"]
        let icons = ["heart", "message", "square.and.arrow.up"]
        
        for (index, title) in actions.enumerated() {
            let btn = UIButton(type: .system)
            if #available(iOS 13.0, *) {
                let config = UIImage.SymbolConfiguration(scale: .small)
                btn.setImage(UIImage(systemName: icons[index], withConfiguration: config), for: .normal)
            }
            btn.setTitle(" \(title)", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            btn.tintColor = DSColor.textSecondary
            // 增加按钮背景，使其看起来像胶囊
            btn.backgroundColor = DSColor.backgroundSecondary.withAlphaComponent(0.5)
            btn.layer.cornerRadius = 20
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            
            actionsStack.addArrangedSubview(btn)
        }
        actionsStack.spacing = 12 // 增加按钮之间的间距
        actionsStack.distribution = .fillProportionally // 根据内容自适应宽度，而不是强制等宽
    }
    
    // MARK: - Configuration
    func configure(with item: FeedItem) {
        // Basic Info
        if let avatarName = item.avatarName {
            avatarView.setImage(UIImage(named: avatarName)) // Assuming assets exist, or placeholders
        } else {
            avatarView.setInitials(String(item.name.prefix(2)).uppercased())
        }
        
        nameLabel.text = item.name
        timeLabel.text = item.time
        contentLabel.setText(item.content)
        
        // Tags
        tagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if item.tags.isEmpty {
            tagsContainer.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            tagsContainer.isHidden = true
        } else {
            tagsContainer.isHidden = false
            tagsContainer.snp.updateConstraints { make in
                make.height.equalTo(24)
            }
            for tagText in item.tags {
                let tag = DSTag(text: tagText, style: .primary)
                tagsContainer.addArrangedSubview(tag)
            }
        }
        
        // Dynamic Content
        dynamicContainer.subviews.forEach { $0.removeFromSuperview() }
        
        switch item.type {
        case .banner(let style, let msg):
            let banner = DSBannerView(style: style, message: msg)
            dynamicContainer.addSubview(banner)
            banner.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
        case .image(let imgName, let title, let sub):
            let imgCard = DSImageCardView()
            imgCard.imageView.image = UIImage(named: imgName) // Placeholder if not found
            imgCard.titleLabel.setText(title)
            imgCard.subtitleLabel.setText(sub)
            imgCard.cardView.elevation = .none // Remove nested shadow if preferred
            imgCard.cardView.contentView.backgroundColor = DSColor.backgroundPrimary
            
            dynamicContainer.addSubview(imgCard)
            imgCard.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
        case .interactive:
            let tf = DSTextField(iconName: "magnifyingglass", placeholder: "Search or comment...")
            let btn = DSButton(title: "Send", style: .primary, size: .medium)
            
            dynamicContainer.addSubview(tf)
            dynamicContainer.addSubview(btn)
            
            tf.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(44)
            }
            
            btn.snp.makeConstraints { make in
                make.top.equalTo(tf.snp.bottom).offset(8)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(80)
            }
            
        case .loading:
            let loading = DSLoadingView()
            loading.startAnimating(text: "Loading related content...")
            dynamicContainer.addSubview(loading)
            loading.snp.makeConstraints { make in
                make.top.bottom.centerX.equalToSuperview()
                make.height.equalTo(100)
            }
            
        case .empty:
            let empty = DSEmptyStateView(
                imageName: "tray",
                title: "Content Removed",
                message: "This content is no longer available.",
                actionTitle: "Learn More"
            )
            dynamicContainer.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
        case .mixed:
            let banner = DSBannerView(style: .warning, message: "Mixed content warning")
            let subLabel = DSLabel(text: "Additional details below.", style: .caption)
            
            dynamicContainer.addSubview(banner)
            dynamicContainer.addSubview(subLabel)
            
            banner.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
            }
            
            subLabel.snp.makeConstraints { make in
                make.top.equalTo(banner.snp.bottom).offset(8)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: - View Controller
class DSComplexListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var items: [FeedItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Complex Feed"
        view.backgroundColor = DSColor.backgroundPrimary
        
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DSComplexFeedCell.self, forCellReuseIdentifier: DSComplexFeedCell.identifier)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadData() {
        items = [
            FeedItem(
                avatarName: nil,
                name: "System Admin",
                time: "2 mins ago",
                content: "System maintenance is scheduled for tonight. Please save your work.",
                type: .banner(.info, "Maintenance starts at 02:00 AM UTC"),
                tags: ["Urgent", "System"]
            ),
            FeedItem(
                avatarName: nil,
                name: "Alice Designer",
                time: "1 hour ago",
                content: "Check out the new design system components! They look amazing and are easy to use.",
                type: .image("placeholder", "Design System v2.0", "Includes new buttons, cards, and more."),
                tags: ["Design", "UI/UX", "Update"]
            ),
            FeedItem(
                avatarName: nil,
                name: "Bob Developer",
                time: "3 hours ago",
                content: "Can someone help me debug this issue? I can't seem to find the root cause.",
                type: .mixed,
                tags: ["Help", "Bug"]
            ),
            FeedItem(
                avatarName: nil,
                name: "Charlie Product",
                time: "5 hours ago",
                content: "What do you think about the new feature proposal? Leave your feedback below.",
                type: .interactive,
                tags: ["Feedback", "Product"]
            ),
            FeedItem(
                avatarName: nil,
                name: "David Manager",
                time: "1 day ago",
                content: "Weekly report is generating...",
                type: .loading,
                tags: []
            ),
            FeedItem(
                avatarName: nil,
                name: "Eva User",
                time: "2 days ago",
                content: "This post has been flagged by moderators.",
                type: .empty,
                tags: ["Flagged"]
            )
        ]
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DSComplexFeedCell.identifier, for: indexPath) as? DSComplexFeedCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}
