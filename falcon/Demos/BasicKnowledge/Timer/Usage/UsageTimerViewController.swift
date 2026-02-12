//
//  UsageTimerViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/6.
//

import UIKit
import SnapKit

class UsageTimerViewController: UIViewController {
    
    struct Item {
        let title: String
        let subtitle: String
        let icon: String
        let action: () -> Void
    }
    
    lazy var dataList: [Item] = [
        Item(title: "错误用法: 循环引用", subtitle: "Target 强引用 self，导致无法释放", icon: "xmark.circle.fill", action: { [weak self] in
            let vc = TimerStrongDemoViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }),
        Item(title: "正确用法: Block + Weak", subtitle: "使用 Block API 并捕获 weak self", icon: "checkmark.circle.fill", action: { [weak self] in
            let vc = TimerWeakDemoViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = DSColor.backgroundPrimary
        tableView.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.m, right: 0)
        tableView.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timer Usage"
        view.backgroundColor = DSColor.backgroundPrimary
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension UsageTimerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as! DSCardListCell
        let item = dataList[indexPath.row]
        cell.configure(title: item.title, subtitle: item.subtitle, iconName: item.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataList[indexPath.row].action()
    }
}

// MARK: - 演示: 错误用法 (循环引用)

class TimerStrongDemoViewController: UIViewController {
    var timer: Timer?
    
    deinit {
        print("❌ TimerStrongDemoViewController deinit")
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "❌ 循环引用示例"
        view.backgroundColor = .white
        
        let label = DSLabel(style: .body)
        label.text = "当前 Timer 强引用了 self。\n请尝试点击返回按钮退出页面。\n\n观察控制台：\n❌ 不会打印 deinit 日志\n❌ Timer 会一直运行"
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        // ❌ 错误做法：导致循环引用
        print("👉 开始 Timer (Strong)")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 注意：这里没有在 viewDidDisappear invalidate timer，是为了演示内存泄漏
        // 如果这里 invalidate，虽然打破了循环引用，但并不是 Timer 这里的初衷（我们希望它随对象生命周期自动管理，或者手动管理）
        // 关键是：只要 timer 还在运行，它就强引用 self。self 不释放，deinit 不走。
    }
    
    @objc func timerAction() {
        print("❌ [Strong] Timer 运行中... self: \(self)")
    }
}

// MARK: - 演示: 正确用法 (Block + Weak)

class TimerWeakDemoViewController: UIViewController {
    var timer: Timer?
    
    deinit {
        print("✅ TimerWeakDemoViewController deinit")
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "✅ 正确用法示例"
        view.backgroundColor = .white
        
        let label = DSLabel(style: .body)
        label.text = "使用了 Block API + weak self。\n请尝试点击返回按钮退出页面。\n\n观察控制台：\n✅ 会立即打印 deinit 日志\n✅ Timer 自动停止"
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(DSSpacing.l)
        }
        
        // ✅ 正确做法
        print("👉 开始 Timer (Weak)")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            print("✅ [Weak] Timer 运行中... self: \(self)")
        }
    }
}
