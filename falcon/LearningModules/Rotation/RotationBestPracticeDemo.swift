//
//  RotationBestPracticeDemo.swift
//  falcon
//
//  Created by Trae on 2026/2/12.
//

import UIKit
import SnapKit

// MARK: - 0. Menu Controller
class RotationBestPracticeMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rotation Best Practices"
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        
        let btn1 = createButton(title: "1. 标准竖屏页面 (Portrait Only)", action: #selector(pushPortrait))
        let btn2 = createButton(title: "2. 强制横屏页面 (Push Video)", action: #selector(pushLandscape))
        let btn3 = createButton(title: "3. 模态横屏页面 (Modal Video)", action: #selector(presentLandscape))
        let btn4 = createButton(title: "4. 交互式调试控制台 (Legacy)", action: #selector(pushLegacyDemo))
        
        stack.addArrangedSubview(btn1)
        stack.addArrangedSubview(btn2)
        stack.addArrangedSubview(btn3)
        stack.addArrangedSubview(btn4)
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    @objc private func pushPortrait() {
        let vc = PortraitOnlyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func pushLandscape() {
        let vc = LandscapeVideoViewController()
        vc.title = "Push Video"
        // 通常视频页建议用 present (模态) 方式，效果更自然
        // 但这里演示 Push 也可以，只要处理好旋转
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func presentLandscape() {
        let vc = LandscapeVideoViewController()
        vc.title = "Modal Video"
        // 关键：全屏模式下旋转控制才最符合预期，且不会被卡片式样式干扰
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func pushLegacyDemo() {
        let vc = RotationDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Rotation Config
    // 菜单页通常支持竖屏即可
    override var shouldAutorotate: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}

// MARK: - 1. Standard Portrait Page
class PortraitOnlyViewController: UIViewController {
    
    override func viewDidLoad() {
        print("1.viewDidLoad")

        super.viewDidLoad()
        title = "Portrait Only"
        view.backgroundColor = .systemYellow
        
        let label = UILabel()
        label.text = "这个页面只支持竖屏\n无论你怎么转手机，它都不会动"
        label.numberOfLines = 0
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("2.viewWillAppear")

        super.viewWillAppear(animated)
    }
    
    // 核心配置：只支持竖屏
    override var shouldAutorotate: Bool {
        true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        print("3.supportedInterfaceOrientations")
        return .portrait
    }
}

// MARK: - 2. Forced Landscape Page (Video Style)
class LandscapeVideoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Player"
        view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "强制横屏模式\n(模拟视频播放)"
        label.textColor = .white
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 添加退出按钮
        let backBtn = UIButton(type: .system)
        backBtn.setTitle("关闭 / 返回", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.backgroundColor = .systemRed
        backBtn.layer.cornerRadius = 8
        backBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Enter & Exit Rotation Logic
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进入时：强制旋转为横屏
        forceOrientation(.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 离开时：如果是正在从父容器移除（Back），则恢复竖屏
        if isMovingFromParent || isBeingDismissed {
            forceOrientation(.portrait)
        }
    }
    
    @objc private func closeAction() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - Rotation Configuration
    
    // 1. 允许自动旋转 (必须为 true，否则强制旋转后会锁死无法恢复，或者转场时系统无法调整方向)
    override var shouldAutorotate: Bool { true }
    
    // 2. 只支持横屏
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    
    // 3. 如果是 Present 进来的，首选横屏
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
    
    // MARK: - Helper
    private func forceOrientation(_ orientation: UIInterfaceOrientation) {
        // 1. 修改 AppDelegate 全局锁
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if orientation == .portrait {
                // 恢复为默认配置（例如只允许竖屏，或者允许所有）
                appDelegate.orientationLock = .allButUpsideDown 
            } else {
                // 允许所有方向，以便能转过去
                appDelegate.orientationLock = .allButUpsideDown
            }
        }
        
        // 2. 请求系统旋转
        if #available(iOS 16.0, *) {
            let mask = UIInterfaceOrientationMask(rawValue: UInt(1) << orientation.rawValue)
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
            view.window?.windowScene?.requestGeometryUpdate(geometryPreferences) { error in
                print("Rotation error: \(error)")
            }
        } else {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}
