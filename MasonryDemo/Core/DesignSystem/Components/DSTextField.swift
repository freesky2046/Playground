//
//  DSTextField.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

/// Design System Standard TextField
/// 包含：图标、输入框、右侧按钮（如密码可见性切换）、背景样式
public class DSTextField: UIView {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = DSColor.backgroundSecondary
        v.layer.cornerRadius = DSSpacing.radiusMedium
        return v
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.textSecondary
        return iv
    }()
    
    public let textField: UITextField = {
        let tf = UITextField()
        tf.textColor = DSColor.textPrimary
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.tintColor = DSColor.brand
        return tf
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = DSColor.textSecondary
        btn.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Properties
    public var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    public var placeholder: String? {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes: [.foregroundColor: DSColor.textPlaceholder]
            )
        }
    }
    
    public var isSecureTextEntry: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    public var keyboardType: UIKeyboardType {
        get { return textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    public var returnKeyType: UIReturnKeyType {
        get { return textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    public var rightButtonAction: (() -> Void)?
    
    // MARK: - Init
    public init(iconName: String? = nil, placeholder: String? = nil) {
        super.init(frame: .zero)
        setupUI()
        
        if let iconName = iconName {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        
        self.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50) // 标准高度
        }
        
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(DSSpacing.m)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        containerView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(DSSpacing.s)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalToSuperview().offset(-DSSpacing.m)
        }
    }
    
    // MARK: - Public Config
    public func setRightButton(iconName: String, action: @escaping () -> Void) {
        rightButton.setImage(UIImage(systemName: iconName), for: .normal)
        rightButtonAction = action
        
        if rightButton.superview == nil {
            containerView.addSubview(rightButton)
            rightButton.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-DSSpacing.s)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(40) // 增大点击区域
            }
            
            // 更新 TextField 约束，避让右侧按钮
            textField.snp.remakeConstraints { make in
                make.left.equalTo(iconImageView.snp.right).offset(DSSpacing.s)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview()
                make.right.equalTo(rightButton.snp.left).offset(-DSSpacing.xs)
            }
        }
    }
    
    public func updateRightButtonIcon(_ iconName: String) {
        rightButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @objc private func rightButtonTapped() {
        rightButtonAction?()
    }
}
