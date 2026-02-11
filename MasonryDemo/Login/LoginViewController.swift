//
//  LoginViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: DSLabel = {
        let label = DSLabel(style: .h1)
        label.text = "Welcome Back"
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: DSLabel = {
        let label = DSLabel(style: .body)
        label.text = "Please sign in to continue"
        label.textColor = DSColor.textSecondary
        return label
    }()
    
    private let usernameField: DSTextField = {
        let tf = DSTextField(iconName: "person.fill", placeholder: "Username")
        tf.returnKeyType = .next
        return tf
    }()
    
    private let passwordField: DSTextField = {
        let tf = DSTextField(iconName: "lock.fill", placeholder: "Password")
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var loginButton: DSButton = {
        let btn = DSButton(title: "Sign In", style: .primary)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(DSColor.textSecondary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        md_hideNavigationBar = true // 隐藏导航栏
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(DSSpacing.xxl * 2)
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(DSSpacing.xs)
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        let stackView = UIStackView(arrangedSubviews: [usernameField, passwordField])
        stackView.axis = .vertical
        stackView.spacing = DSSpacing.l
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(DSSpacing.xxl)
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(DSSpacing.xl)
            make.left.right.equalToSuperview().inset(DSSpacing.l)
            make.height.equalTo(50)
        }
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(DSSpacing.m)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupActions() {
        // 密码可见性切换
        passwordField.setRightButton(iconName: "eye.slash.fill") { [weak self] in
            guard let self = self else { return }
            self.passwordField.isSecureTextEntry.toggle()
            let newIcon = self.passwordField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
            self.passwordField.updateRightButtonIcon(newIcon)
        }
        
        // 键盘处理
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func handleLogin() {
        dismissKeyboard()
        
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            // 简单的抖动动画反馈
            shake(view: loginButton)
            return
        }
        
        // 模拟登录加载
        loginButton.isEnabled = false
        loginButton.setTitle("Signing in...", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            // 切换到主页面
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // 简单的转场动画
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = MDTabbarController()
                }, completion: nil)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func shake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        view.layer.add(animation, forKey: "shake")
    }
}
