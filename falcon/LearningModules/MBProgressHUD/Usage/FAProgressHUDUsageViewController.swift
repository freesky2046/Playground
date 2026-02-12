import UIKit
import SnapKit

class FAProgressHUDUsageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 仅作演示按钮布局，点击触发不同 HUD
        setupButtons()
    }
    
    // MARK: - 场景 1: 简单的 Loading
    @objc func showSimpleIndeterminate() {
        let hud = FAProgressHUD.showAdded(to: self.view, animated: true)//showaddedTo: self.view, animated: true)
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hud.hide(animated: true)
        }
    }
    
    // MARK: - 场景 2: 带文字的 Loading
    @objc func showWithLabel() {
        let hud = FAProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hud.hide(animated: true)
        }
    }
    
    // MARK: - 场景 3: 带详情文字的 Loading
    @objc func showWithDetails() {
        let hud = FAProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.detailsLabel.text = "Parsing data\n(1/10)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hud.hide(animated: true)
        }
    }
    
    // MARK: - 场景 4: 纯文本提示 (Toast)
    @objc func showTextOnly() {
        let hud = FAProgressHUD(frame: view.bounds)
        hud.mode = .text
        hud.label.text = "Message Sent"
        hud.margin = 10.0 // Toast 通常紧凑一点
        view.addSubview(hud)
        hud.show(animated: true)
        // 2秒后自动隐藏
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    // MARK: - 场景 5: 自定义视图 (如完成状态)
    @objc func showCustomView() {
        let hud = FAProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .customView
        
        // 使用自定义图片
        let image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        hud.customView = imageView
        
        hud.label.text = "Completed"
        
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    // MARK: - 场景 6: 切换状态 (Loading -> Success)
    @objc func showSwitchState() {
        let hud = FAProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Uploading..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 切换到成功状态
            let image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            imageView.tintColor = .white
            
            hud.customView = imageView
            hud.mode = .customView
            hud.label.text = "Done"
            
            hud.hide(animated: true, afterDelay: 1.5)
        }
    }

    // ... 辅助按钮代码省略 ...
    func setupButtons() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let actions: [(String, Selector)] = [
            ("Indeterminate", #selector(showSimpleIndeterminate)),
            ("With Label", #selector(showWithLabel)),
            ("With Details", #selector(showWithDetails)),
            ("Text Only (Toast)", #selector(showTextOnly)),
            ("Custom View (Success)", #selector(showCustomView)),
            ("State Switch", #selector(showSwitchState))
        ]
        
        for (title, selector) in actions {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.addTarget(self, action: selector, for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }
    }
}
