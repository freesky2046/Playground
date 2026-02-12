//
//  RotationDemoViewController.swift
//  falcon
//
//  Created by Trae on 2026/2/12.
//

import UIKit
import SnapKit

class RotationDemoViewController: UIViewController {

    // MARK: - Properties
    
    // 控制是否允许自动旋转
    var allowAutorotate: Bool = true {
        didSet {
            // 触发旋转状态更新
            if #available(iOS 16.0, *) {
                setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
    
    // 控制支持的方向
    var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown {
        didSet {
            if #available(iOS 16.0, *) {
                setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = DSColor.textPrimary
        return label
    }()
    
    private lazy var rotateSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return sw
    }()
    
    private lazy var orientationSegment: UISegmentedControl = {
        let items = ["All", "Portrait", "Landscape"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    private lazy var forcePortraitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("强制竖屏 (Force Portrait)", for: .normal)
        btn.backgroundColor = DSColor.textPrimary
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(forcePortrait), for: .touchUpInside)
        return btn
    }()
    
    private lazy var forceLandscapeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("强制横屏 (Force Landscape)", for: .normal)
        btn.backgroundColor = DSColor.textPrimary
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(forceLandscape), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Screen Rotation"
        view.backgroundColor = DSColor.backgroundPrimary
        
        setupUI()
        updateStatusLabel()
        
        // 监听设备方向变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            createControlRow(title: "自动旋转 (Autorotate)", control: rotateSwitch),
            createControlRow(title: "支持方向", control: orientationSegment),
            statusLabel,
            forcePortraitButton,
            forceLandscapeButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        forcePortraitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        forceLandscapeButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    private func createControlRow(title: String, control: UIView) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        label.textColor = DSColor.textPrimary
        
        container.addSubview(label)
        container.addSubview(control)
        
        label.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        control.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func switchChanged(_ sender: UISwitch) {
        allowAutorotate = sender.isOn
        updateStatusLabel()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            supportedOrientations = .allButUpsideDown
        case 1:
            supportedOrientations = .portrait
        case 2:
            supportedOrientations = .landscape
        default:
            break
        }
        updateStatusLabel()
    }
    
    @objc private func forcePortrait() {
        requestGeometryUpdate(orientation: .portrait)
    }
    
    @objc private func forceLandscape() {
        requestGeometryUpdate(orientation: .landscapeRight)
    }
    
    @objc private func deviceOrientationDidChange() {
        updateStatusLabel()
    }
    
    private func updateStatusLabel() {
        let orientation = UIDevice.current.orientation
        var orientationStr = "Unknown"
        switch orientation {
        case .portrait: orientationStr = "Portrait"
        case .portraitUpsideDown: orientationStr = "PortraitUpsideDown"
        case .landscapeLeft: orientationStr = "LandscapeLeft"
        case .landscapeRight: orientationStr = "LandscapeRight"
        case .faceUp: orientationStr = "FaceUp"
        case .faceDown: orientationStr = "FaceDown"
        default: break
        }
        
        statusLabel.text = """
        当前设备方向: \(orientationStr)
        shouldAutorotate: \(allowAutorotate)
        supportedOrientations: \(supportedOrientationsDescription)
        """
    }
    
    private var supportedOrientationsDescription: String {
        if supportedOrientations == .allButUpsideDown { return "All" }
        if supportedOrientations == .portrait { return "Portrait Only" }
        if supportedOrientations == .landscape { return "Landscape Only" }
        return "Custom"
    }
    
    // MARK: - Rotation Logic
    
    // 1. 是否支持自动旋转 (shouldAutorotate)
    // 决定当前界面是否会跟随设备物理旋转而旋转
    // ⚠️ 注意：必须确保父容器（如 NavigationController）将此方法调用传递给当前 VC
    override var shouldAutorotate: Bool {
        return allowAutorotate
    }
    
    // 2. 支持的方向 (supportedInterfaceOrientations)
    // 决定当前界面支持哪些方向
    // ⚠️ 注意：这个集合必须是 Info.plist 和 AppDelegate 中允许方向的子集
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientations
    }
    
    // 3. 强制旋转工具方法
    // 核心原理：通知系统界面方向需要更新
    private func requestGeometryUpdate(orientation: UIInterfaceOrientation) {
        
        // 关键点：如果 AppDelegate 锁死了方向，这里强制旋转也会失败
        // 所以通常需要配合修改 AppDelegate 的 orientationLock
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // 临时放开全局限制，允许旋转到目标方向
            appDelegate.orientationLock = .allButUpsideDown
        }
        
        if #available(iOS 16.0, *) {
            // iOS 16+ 新 API: requestGeometryUpdate
            guard let windowScene = view.window?.windowScene else { return }
            let mask = UIInterfaceOrientationMask(rawValue: UInt(1) << orientation.rawValue)
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("Rotation error: \(error.localizedDescription)")
            }
        } else {
            // iOS 15及以下: KVC 黑魔法
            let value = orientation.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    // 4. 监听屏幕旋转大小变化
    // 当屏幕旋转发生时，系统会调用此方法
    // 可以在这里处理布局变化（如果 AutoLayout 不够用的话）
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // 旋转动画过程中更新布局或UI
            self.updateStatusLabel()
            print("Rotating to size: \(size)")
        }) { _ in
            // 旋转结束
            print("Rotation finished")
        }
    }
    
    // MARK: - Clean Up
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 离开页面时，通常建议恢复到默认的竖屏状态
        if isMovingFromParent {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                // 恢复全局锁定为竖屏（如果 App 是竖屏为主）
                // appDelegate.orientationLock = .portrait 
                // 或者恢复为默认
                 appDelegate.orientationLock = .allButUpsideDown
            }
            
            // 强制转回竖屏
            if #available(iOS 16.0, *) {
                let windowScene = view.window?.windowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
