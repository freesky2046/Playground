//
//  LockBlockingViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/4.
//

import UIKit

class LockBlockingViewController: UIViewController {

    private let lock = NSLock()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        let btn1 = createButton(title: "1. 主线程执行耗时任务 (无竞争)", action: #selector(testCriticalSectionBlocking))
        let btn2 = createButton(title: "2. 主线程等待锁 (有竞争)", action: #selector(testLockContentionBlocking))
        let btn3 = createButton(title: "3. 正常UI响应测试", action: #selector(testUIResponsiveness))
        
        let stack = UIStackView(arrangedSubviews: [btn1, btn2, btn3])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // 情景1: 锁本身没竞争，但锁保护的代码太慢
    // 结果: 主线程卡死，因为主线程在执行 sleep
    @objc func testCriticalSectionBlocking() {
        print("🟢 1. 开始：主线程尝试拿锁...")
        lock.lock()
        print("✅ 1. 拿到锁：主线程开始执行耗时任务(2秒)...")
        
        // 模拟耗时操作 (如: 写大文件)
        // 注意：这是在主线程执行的！
        Thread.sleep(forTimeInterval: 2.0)
        
        print("🏁 1. 结束：任务完成，释放锁")
        lock.unlock()
    }
    
    // 情景2: 后台线程先拿了锁，主线程想拿锁被挡在门外
    // 结果: 主线程卡死，因为主线程在 lock() 这一行等待
    @objc func testLockContentionBlocking() {
        print("🔵 2. 准备：后台线程先去拿锁...")
        
        // 1. 后台线程先拿锁
        DispatchQueue.global().async {
            self.lock.lock()
            print("🔒 后台线程：拿到锁了，我睡3秒再放开...")
            Thread.sleep(forTimeInterval: 3.0)
            self.lock.unlock()
            print("🔓 后台线程：释放锁了！")
        }
        
        // 2. 主线程 0.5秒后尝试拿锁
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("⚠️ 主线程：我也想要锁，但我可能要被阻塞了...")
            let start = CFAbsoluteTimeGetCurrent()
            
            // ❌ 这里会卡死主线程！直到后台线程释放锁
            self.lock.lock()
            
            let end = CFAbsoluteTimeGetCurrent()
            print("✅ 主线程：终于拿到锁了！等待了 \(String(format: "%.2f", end - start)) 秒")
            self.lock.unlock()
        }
    }
    
    @objc func testUIResponsiveness() {
        print("✨ UI 响应正常：点击了按钮")
        view.backgroundColor = UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return btn
    }
}
