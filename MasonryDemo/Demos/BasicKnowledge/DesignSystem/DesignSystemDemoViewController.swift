//
//  DesignSystemDemoViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

class DesignSystemDemoViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = DSColor.backgroundPrimary
        return sv
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = DSSpacing.l
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: DSSpacing.l, left: DSSpacing.m, bottom: DSSpacing.l, right: DSSpacing.m)
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Design System Components"
        view.backgroundColor = DSColor.backgroundPrimary
        
        setupLayout()
        setupContent()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupContent() {
        addSectionTitle("Typography System")
        
        let h1Label = DSLabel(style: .h1)
        h1Label.text = "Heading 1 Title"
        stackView.addArrangedSubview(h1Label)
        
        let h2Label = DSLabel(style: .h2)
        h2Label.text = "Heading 2 Title"
        stackView.addArrangedSubview(h2Label)
        
        let h3Label = DSLabel(style: .h3)
        h3Label.text = "Heading 3 Title"
        stackView.addArrangedSubview(h3Label)
        
        let bodyLabel = DSLabel(style: .body)
        bodyLabel.text = "This is a body text using standard spacing and typography tokens. It adapts to dark mode automatically and supports dynamic type."
        bodyLabel.numberOfLines = 0
        stackView.addArrangedSubview(bodyLabel)
        
        let captionLabel = DSLabel(style: .caption)
        captionLabel.text = "Caption text for secondary information."
        stackView.addArrangedSubview(captionLabel)
        
        addSectionTitle("Button Components")
        
        let primaryBtn = DSButton(style: .primary, size: .medium)
        primaryBtn.setTitle("Primary Button", for: .normal)
        stackView.addArrangedSubview(primaryBtn)
        
        let secondaryBtn = DSButton(style: .secondary, size: .medium)
        secondaryBtn.setTitle("Secondary Button", for: .normal)
        stackView.addArrangedSubview(secondaryBtn)
        
        let outlineBtn = DSButton(style: .outline, size: .medium)
        outlineBtn.setTitle("Outline Button", for: .normal)
        stackView.addArrangedSubview(outlineBtn)
        
        let smallBtn = DSButton(style: .primary, size: .small)
        smallBtn.setTitle("Small Button", for: .normal)
        // 为了演示居左，包一层
        let smallBtnContainer = UIView()
        smallBtnContainer.addSubview(smallBtn)
        smallBtn.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
        stackView.addArrangedSubview(smallBtnContainer)
        
        addSectionTitle("Semantic Colors")
        
        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.distribution = .fillEqually
        colorStack.spacing = DSSpacing.s
        
        let colors = [
            (DSColor.brand, "Brand"),
            (DSColor.success, "Success"),
            (DSColor.warning, "Warning"),
            (DSColor.error, "Error")
        ]
        
        for (color, name) in colors {
            let v = UIView()
            v.backgroundColor = color
            v.layer.cornerRadius = DSSpacing.radiusMedium
            
            let l = UILabel()
            l.text = name
            l.font = .systemFont(ofSize: 10)
            l.textColor = .white
            l.textAlignment = .center
            v.addSubview(l)
            l.snp.makeConstraints { make in make.center.equalToSuperview() }
            
            v.snp.makeConstraints { make in make.height.equalTo(60) }
            colorStack.addArrangedSubview(v)
        }
        stackView.addArrangedSubview(colorStack)

        addSectionTitle("Banners")
        
        // Info Banner
        let infoBanner = DSBannerView(style: .info, title: "系统提示", message: "这是一个信息提示 Banner，通常用于展示普通通知。", showCloseButton: true)
        stackView.addArrangedSubview(infoBanner)
        
        // Success Banner
        let successBanner = DSBannerView(style: .success, message: "操作成功完成！(无标题模式)")
        stackView.addArrangedSubview(successBanner)
        
        // Warning Banner
        let warningBanner = DSBannerView(style: .warning, title: "警告", message: "您的账户存在安全风险，请尽快修改密码。", showCloseButton: true)
        stackView.addArrangedSubview(warningBanner)
        
        // Error Banner
        let errorBanner = DSBannerView(style: .error, title: "连接失败", message: "无法连接到服务器，请检查您的网络设置。", showCloseButton: true)
        stackView.addArrangedSubview(errorBanner)
        
        addSectionTitle("Cards (Generic)")
        
        // Generic Card
        let card = DSCardView()
        card.elevation = .low
        
        let cardLabel = DSLabel(style: .body)
        cardLabel.text = "这是一个基础卡片容器 (DSCardView)。\n它可以容纳任何自定义视图，并提供标准的圆角和阴影。"
        cardLabel.numberOfLines = 0
        
        card.contentView.addSubview(cardLabel)
        cardLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(DSSpacing.m)
        }
        stackView.addArrangedSubview(card)
        
        addSectionTitle("Image Cards")
        
        // Image Card 1
        let imageCard1 = DSImageCardView()
        // 使用系统图标作为占位图演示
        let placeholder = UIImage(systemName: "photo.artframe")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        imageCard1.configure(
            image: placeholder,
            title: "精美艺术画廊",
            subtitle: "探索最新的数字艺术收藏，感受科技与艺术的完美融合。",
            actionTitle: "查看详情"
        )
        // 模拟图片高度
        imageCard1.imageView.contentMode = .center
        imageCard1.imageView.backgroundColor = DSColor.backgroundSecondary
        stackView.addArrangedSubview(imageCard1)
        
        // Image Card 2 (No Action)
        let imageCard2 = DSImageCardView()
        imageCard2.configure(
            image: UIImage(systemName: "globe.asia.australia.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal),
            title: "全球旅行指南",
            subtitle: "2026年最值得去的10个目的地推荐。"
        )
        imageCard2.imageView.contentMode = .scaleAspectFit
        imageCard2.imageView.backgroundColor = UIColor(hex: 0xE3F2FD)
        stackView.addArrangedSubview(imageCard2)
        
        addSectionTitle("Avatars")
        
        // Avatars Row
        let avatarRow = UIStackView()
        avatarRow.spacing = DSSpacing.m
        avatarRow.alignment = .center
        
        let avatarS = DSAvatar(size: .small)
        avatarS.setInitials("SM")
        
        let avatarM = DSAvatar(size: .medium)
        avatarM.setInitials("MD", backgroundColor: DSColor.warning)
        
        let avatarL = DSAvatar(size: .large)
        avatarL.setInitials("LG", backgroundColor: DSColor.success)
        
        let avatarXL = DSAvatar(size: .xLarge)
        // 模拟图片
        avatarXL.setImage(UIImage(systemName: "person.crop.circle.fill"))
        avatarXL.tintColor = .gray
        
        avatarRow.addArrangedSubview(avatarS)
        avatarRow.addArrangedSubview(avatarM)
        avatarRow.addArrangedSubview(avatarL)
        avatarRow.addArrangedSubview(avatarXL)
        stackView.addArrangedSubview(avatarRow)
        
        addSectionTitle("Tags")
        
        // Tags Row
        let tagsRow = UIStackView()
        tagsRow.spacing = DSSpacing.s
        tagsRow.alignment = .center
        tagsRow.distribution = .fillProportionally
        
        let tag1 = DSTag(text: "Primary", style: .primary)
        let tag2 = DSTag(text: "Success", style: .success)
        let tag3 = DSTag(text: "Warning", style: .warning)
        let tag4 = DSTag(text: "Error", style: .error)
        let tag5 = DSTag(text: "Outline", style: .outline)
        
        tagsRow.addArrangedSubview(tag1)
        tagsRow.addArrangedSubview(tag2)
        tagsRow.addArrangedSubview(tag3)
        tagsRow.addArrangedSubview(tag4)
        tagsRow.addArrangedSubview(tag5)
        stackView.addArrangedSubview(tagsRow)
        
        addSectionTitle("Empty State (Mini)")
        
        // Empty State (Embedded)
        let emptyStateContainer = UIView()
        emptyStateContainer.backgroundColor = DSColor.backgroundSecondary
        emptyStateContainer.layer.cornerRadius = DSSpacing.radiusMedium
        
        let emptyState = DSEmptyStateView(
            imageName: "cart",
            title: "购物车为空",
            message: "您还没有添加任何商品，快去选购吧！",
            actionTitle: "去逛逛"
        )
        emptyStateContainer.addSubview(emptyState)
        emptyState.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(DSSpacing.l)
        }
        
        stackView.addArrangedSubview(emptyStateContainer)
        emptyStateContainer.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        
        addSectionTitle("Loading")
        
        let loadingView = DSLoadingView()
        loadingView.startAnimating(text: "正在加载数据...")
        stackView.addArrangedSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        addSectionTitle("Complex Demos")
        
        let complexDemoBtn = DSButton(title: "Open Complex Feed Demo", style: .primary, size: .large)
        complexDemoBtn.addTarget(self, action: #selector(openComplexDemo), for: .touchUpInside)
        stackView.addArrangedSubview(complexDemoBtn)
    }
    
    @objc private func openComplexDemo() {
        let vc = DSComplexListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addSectionTitle(_ text: String) {
        let label = DSLabel(style: .h2)
        label.text = text
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(DSSpacing.s, after: label)
    }
}
