//
//  FigmaDesignViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/5.
//

import UIKit
import SnapKit

struct TagModel {
    let text: String
    let iconName: String? // SF Symbol name
    let isNew: Bool
    let isHot: Bool
    
    init(text: String, iconName: String? = nil, isNew: Bool = false, isHot: Bool = false) {
        self.text = text
        self.iconName = iconName
        self.isNew = isNew
        self.isHot = isHot
    }
}

class SearchTagCell: UITableViewCell {
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .gray
        return btn
    }()
    
    private lazy var tagsContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerLabel)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(20)
        }
        
        contentView.addSubview(tagsContainer)
        tagsContainer.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-10) // Padding bottom
        }
    }
    
    func configure(title: String, actionIcon: String, tags: [TagModel]) {
        headerLabel.text = title
        actionButton.setImage(UIImage(systemName: actionIcon), for: .normal)
        
        // Remove old tags
        tagsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Layout new tags
        let containerWidth = UIScreen.main.bounds.width - 32
        createFlowLayout(in: tagsContainer, tags: tags, width: containerWidth)
    }
    
    // Simple Flow Layout Generator
    private func createFlowLayout(in view: UIView, tags: [TagModel], width: CGFloat) {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacing: CGFloat = 10
        let lineSpacing: CGFloat = 10
        let height: CGFloat = 32
        
        for tag in tags {
            let tagView = createTagButton(model: tag)
            
            // Calculate size
            let size = tagView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let tagWidth = min(size.width + 24, width) // Add padding
            
            // Check if new line needed
            if currentX + tagWidth > width {
                currentX = 0
                currentY += height + lineSpacing
            }
            
            view.addSubview(tagView)
            tagView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(currentX)
                make.top.equalToSuperview().offset(currentY)
                make.width.equalTo(tagWidth)
                make.height.equalTo(height)
            }
            
            currentX += tagWidth + spacing
        }
        
        // Update container height constraint
        let totalHeight = currentY + height
        view.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
    }
    
    private func createTagButton(model: TagModel) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        
        // Content Stack
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }
        
        // Icon (Optional)
        if let iconName = model.iconName {
            let iv = UIImageView(image: UIImage(systemName: iconName))
            iv.tintColor = .systemCyan // Blueish for star
            iv.contentMode = .scaleAspectFit
            iv.snp.makeConstraints { make in
                make.width.height.equalTo(14)
            }
            stack.addArrangedSubview(iv)
        }
        
        // New/Hot Badge (Optional)
        if model.isNew {
            let badge = createBadge(text: "新", color: .systemRed)
            stack.addArrangedSubview(badge)
        }
        if model.isHot {
            let badge = createBadge(text: "热", color: .systemRed)
            stack.addArrangedSubview(badge)
        }
        
        // Text
        let label = UILabel()
        label.text = model.text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        stack.addArrangedSubview(label)
        
        return container
    }
    
    private func createBadge(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        let container = UIView()
        container.backgroundColor = color
        container.layer.cornerRadius = 7
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(3)
        }
        
        container.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
        return container
    }
}

class BannerCell: UITableViewCell {
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        // Create a gradient placeholder image
        iv.backgroundColor = .systemBlue
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        
        // Add "限时专属购" text label inside
        let label = UILabel()
        label.text = "限时专属购"
        label.textColor = .white
        label.font = .systemFont(ofSize: 40, weight: .heavy)
        label.textAlignment = .center
        iv.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Add decorative gradient layer look
        // Note: Can't easily add CALayer to UIView in lazy var without frame.
        iv.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
        
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bannerImageView)
        bannerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
}

class FigmaDesignViewController: UIViewController {

    // MARK: - UI Components
    
    private lazy var customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "搜索文物"
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .black
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("搜索", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return btn
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(SearchTagCell.self, forCellReuseIdentifier: "SearchTagCell")
        tv.register(BannerCell.self, forCellReuseIdentifier: "BannerCell")
        return tv
    }()
    
    // MARK: - Data
    private let historyTags: [TagModel] = [
        TagModel(text: "文物故事"),
        TagModel(text: "古滇王"),
        TagModel(text: "马踏飞燕"),
        TagModel(text: "博物馆预约"),
        TagModel(text: "越王勾践"),
        TagModel(text: "愿吾弟发扬黄埔精神...", iconName: nil), // Long text
        TagModel(text: "瓷"),
        TagModel(text: "文物"),
        TagModel(text: "博物馆预约"),
        TagModel(text: "最新资讯"),
        TagModel(text: "嘴里乾坤大"),
        TagModel(text: "文人书生")
    ]
    
    private let guessTags: [TagModel] = [
        TagModel(text: "文物故事", iconName: "star.fill"),
        TagModel(text: "古滇王"),
        TagModel(text: "马踏飞燕"),
        TagModel(text: "博物馆预约"),
        TagModel(text: "文物", isNew: true),
        TagModel(text: "越王勾践", isHot: true),
        TagModel(text: "古滇王"),
        TagModel(text: "红色文博"),
        TagModel(text: "博物馆预约"),
        TagModel(text: "最新资讯"),
        TagModel(text: "嘴里乾坤大"),
        TagModel(text: "文人书生")
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 1. Top Bar
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        customNavBar.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        customNavBar.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        
        customNavBar.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(10)
            make.right.equalTo(searchButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        
        searchContainer.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        searchContainer.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // 2. TableView
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension FigmaDesignViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTagCell", for: indexPath) as! SearchTagCell
            cell.configure(title: "搜索历史", actionIcon: "trash", tags: historyTags)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTagCell", for: indexPath) as! SearchTagCell
            cell.configure(title: "猜你喜欢", actionIcon: "arrow.clockwise", tags: guessTags)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as! BannerCell
            return cell
        }
    }
}
