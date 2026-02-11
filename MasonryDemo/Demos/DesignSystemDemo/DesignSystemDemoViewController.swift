//
//  DesignSystemDemoViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

class DesignSystemDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        title = "Design System Demo"
        
        setupUI()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 1. Typography
        let titleLabel = DSLabel(text: "Typography System", style: .h1)
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.l)
            make.left.equalToSuperview().offset(DSSpacing.m)
        }
        
        let h2Label = DSLabel(text: "Heading 2", style: .h2)
        container.addSubview(h2Label)
        h2Label.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.s)
            make.left.equalTo(titleLabel)
        }
        
        let bodyLabel = DSLabel(text: "This is a body text using standard spacing and typography tokens. It adapts to dark mode automatically.", style: .body)
        bodyLabel.numberOfLines = 0
        container.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(h2Label.snp.bottom).offset(DSSpacing.s)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
        }
        
        // 2. Buttons
        let btnTitle = DSLabel(text: "Button Components", style: .h2)
        container.addSubview(btnTitle)
        btnTitle.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(DSSpacing.xl)
            make.left.equalToSuperview().offset(DSSpacing.m)
        }
        
        let primaryBtn = DSButton(title: "Primary Button", style: .primary)
        container.addSubview(primaryBtn)
        primaryBtn.snp.makeConstraints { make in
            make.top.equalTo(btnTitle.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.height.equalTo(44)
        }
        
        let secondaryBtn = DSButton(title: "Secondary Button", style: .secondary)
        container.addSubview(secondaryBtn)
        secondaryBtn.snp.makeConstraints { make in
            make.top.equalTo(primaryBtn.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.height.equalTo(44)
        }
        
        let outlineBtn = DSButton(title: "Outline Button", style: .outline)
        container.addSubview(outlineBtn)
        outlineBtn.snp.makeConstraints { make in
            make.top.equalTo(secondaryBtn.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.height.equalTo(44)
        }
        
        // 3. Colors
        let colorTitle = DSLabel(text: "Semantic Colors", style: .h2)
        container.addSubview(colorTitle)
        colorTitle.snp.makeConstraints { make in
            make.top.equalTo(outlineBtn.snp.bottom).offset(DSSpacing.xl)
            make.left.equalToSuperview().offset(DSSpacing.m)
        }
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = DSSpacing.s
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(colorTitle.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-DSSpacing.xl)
        }
        
        let colors = [DSColor.brand, DSColor.success, DSColor.warning, DSColor.error]
        for color in colors {
            let v = UIView()
            v.backgroundColor = color
            v.layer.cornerRadius = DSSpacing.radiusMedium
            stack.addArrangedSubview(v)
        }
    }
}
