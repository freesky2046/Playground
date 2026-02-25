//
//  MDEmptyView.swift
//  falcon
//
//  Created by 周明 on 2026/2/25.
//

import Foundation
import UIKit
import SnapKit

extension UIView {
    private struct AssociatedObjectKeys {
        static var kMDEmptyViewKey: UInt8 = 0
    }
    
    var emptyView: MDEmptyView? {
        get {
           return  objc_getAssociatedObject(self, &AssociatedObjectKeys.kMDEmptyViewKey) as? MDEmptyView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kMDEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showEmptyView(type: MDEmptyView.MDEmptyViewType = .empty) {
        emptyView?.removeFromSuperview()
        self.emptyView = MDEmptyView.show(in: self, type: type)
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
        self.emptyView = nil
    }
}

class MDEmptyView: UIView {
    
    enum MDEmptyViewType {
        case network
        case empty
        case custom(title: String, image: String, buttonTitile: String)
        
        var title: String {
            switch self {
            case .empty:
                return "数据为空"
            case .network:
                return "无网络"
            case .custom(let title, _, _):
                return title
            }
        }
        
        var image: String {
            switch self {
            case .empty: return "placeholder_instagram"
            case .network: return "placeholder_remote"
            case .custom(_, let image,_): return image
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .empty: return "重试"
            case .network: return "重试"
            case .custom(_, _, let buttonTitle): return buttonTitle
            }
        }
    }
    
    var onTap: (() -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill // 和axis一致方向, 默认为fill
        stackView.alignment = .center  // 和axis垂直方向
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private lazy var button: DSButton = {
        let button = DSButton(title: "", style: .primary)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    static func show(in superView: UIView, type: MDEmptyViewType) -> MDEmptyView {
        let emptyView = MDEmptyView(frame: .zero)
        superView.addSubview(emptyView)
        emptyView.update(with: type)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return emptyView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(buttonDidPressed), for: .touchUpInside)
    }
    
    func update(with type: MDEmptyViewType) {
        titleLabel.text = type.title
        imageView.image = UIImage(named: type.image)
        button.isHidden = type.buttonTitle.isEmpty == true
        button.setTitle(type.buttonTitle, for: .normal)
    }
    
    @objc func buttonDidPressed() {
        onTap?()
    }
}
