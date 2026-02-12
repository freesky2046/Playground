//
//  GistDetailViewController.swift
//  falcon
//
//  Created by falcon on 2026/2/12.
//

import UIKit
import SnapKit

class GistDetailViewController: UIViewController, RouteCompatible {
    
    // MARK: - RouteCompatible
    // 解析传递过来的参数
    func handleParams(params: [String : String]) {
        if let name = params["name"] {
            self.title = name
            nameLabel.text = name
        }
        if let age = params["age"] {
            infoLabel.text = "Age: \(age)"
        }
    }
    
    // MARK: - UI Components
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypography.h1
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypography.h2
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = DSColor.backgroundPrimary
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, infoLabel])
        stack.axis = .vertical
        stack.spacing = DSSpacing.m
        stack.alignment = .center
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
