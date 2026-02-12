//
//  FAProgressHUDUsageViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/12.
//

import Foundation

import UIKit
import SnapKit

public class FAProgressHUD: UIView {
    
    // MARK: - Types
    public enum Mode {
        case indeterminate // 菊花 (默认)
        case text          // 纯文本
        case customView    // 自定义视图 (如成功/失败图标)
    }
    
    // MARK: - Properties
    public var mode: Mode = .indeterminate {
        didSet {
            updateIndicators()
            setNeedsUpdateConstraints()
        }
    }
    
    // 容器 (Bezel)
    public let bezelView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.9) // 深色背景
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    // 标题
    public let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // 详情
    public let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(white: 0.9, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.8, alpha: 0.6)
        return backgroundView
    }()
    
    // 自定义视图 (用于 mode == .customView)
    public var customView: UIView? {
        didSet {
            if mode == .customView {
                updateIndicators()
                setNeedsUpdateConstraints()
            }
        }
    }
    
    // 菊花
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        view.hidesWhenStopped = true
        return view
    }()
    
    // 边距配置
    public var margin: CGFloat = 20.0
    public var padding: CGFloat = 10.0
    public var minSize: CGSize = CGSize(width: 100, height: 100)
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubview(bezelView)
        bezelView.addSubview(label)
        bezelView.addSubview(detailsLabel)
        bezelView.addSubview(activityIndicator)
        updateIndicators()
    }
    
    // MARK: - Public Methods
    
    /// 显示 HUD 到指定视图
    @discardableResult
    public static func showAdded(to view: UIView, animated: Bool) -> FAProgressHUD {
        let hud = FAProgressHUD(frame: view.bounds)
        view.addSubview(hud)
        hud.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hud.show(animated: animated)
        return hud
    }
    
    /// 隐藏指定视图中的 HUD
    @discardableResult
    public static func hide(for view: UIView, animated: Bool) -> Bool {
        if let hud = view.subviews.reversed().first(where: { $0 is FAProgressHUD }) as? FAProgressHUD {
            hud.hide(animated: animated)
            return true
        }
        return false
    }
    
    public func show(animated: Bool) {
        if animated {
            backgroundView.alpha = 0.0
            bezelView.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.backgroundView.alpha = 1.0
                self.bezelView.alpha = 1.0
            }
        } else {
            backgroundView.alpha = 1.0
            bezelView.alpha = 1.0
        }
    }
    
    public func hide(animated: Bool, afterDelay delay: TimeInterval = 0) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.hide(animated: animated, afterDelay: 0)
            }
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.alpha = 0.0
                self.bezelView.alpha = 0.0
            }) { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Internal Logic
    private func updateIndicators() {
        switch mode {
        case .indeterminate:
            activityIndicator.startAnimating()
            customView?.isHidden = true
        case .text:
            activityIndicator.stopAnimating()
            customView?.isHidden = true
        case .customView:
            activityIndicator.stopAnimating()
            if let customView = customView {
                customView.isHidden = false
                if customView.superview != bezelView {
                    bezelView.addSubview(customView)
                }
            }
        }
    }
    
    // MARK: - Layout (SnapKit)
    public override func updateConstraints() {
        
        // 1. 布局 Bezel (容器)
        bezelView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            // 限制最大宽度，防止贴边
            make.width.lessThanOrEqualToSuperview().offset(-margin * 2)
            make.height.lessThanOrEqualToSuperview().offset(-margin * 2)
            // 最小尺寸
            make.width.greaterThanOrEqualTo(minSize.width)
            make.height.greaterThanOrEqualTo(minSize.height)
        }
        
        // 2. 收集可见子视图
        var subviews: [UIView] = []
        
        // 顶部视图 (Indicator 或 CustomView)
        if mode == .indeterminate {
            subviews.append(activityIndicator)
        } else if mode == .customView, let customView = customView, !customView.isHidden {
            subviews.append(customView)
        }
        
        // 文本视图
        if let text = label.text, !text.isEmpty {
            subviews.append(label)
        }
        if let details = detailsLabel.text, !details.isEmpty {
            subviews.append(detailsLabel)
        }
        
        // 3. 垂直堆叠布局
        if subviews.isEmpty {
             // 空状态处理（可选）
        } else {
            for (index, view) in subviews.enumerated() {
                view.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview()

                    
                    // Top 约束
                    if index == 0 {
                        make.top.equalToSuperview().offset(margin)
                    } else {
                        make.top.equalTo(subviews[index - 1].snp.bottom).offset(padding)
                    }
                    
                    // Bottom 约束 (如果是最后一个)
                    if index == subviews.count - 1 {
                        make.bottom.equalToSuperview().offset(-margin)
                    }
                }
            }
        }
        
        super.updateConstraints()
    }
}
