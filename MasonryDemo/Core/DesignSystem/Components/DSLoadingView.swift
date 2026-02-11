//
//  DSLoadingView.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Loading Component
/// 标准化的加载指示器
public class DSLoadingView: UIView {
    
    // MARK: - UI Components
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [activityIndicator, label])
        sv.axis = .vertical
        sv.spacing = DSSpacing.xs
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    public func startAnimating(text: String? = nil) {
        activityIndicator.startAnimating()
        if let text = text {
            label.text = text
            label.isHidden = false
        } else {
            label.isHidden = true
        }
        self.isHidden = false
    }
    
    public func stopAnimating() {
        activityIndicator.stopAnimating()
        self.isHidden = true
    }
}
