//
//  UsageTimerViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import UIKit

class UsageTimerViewController: UIViewController {
    weak var selectorTimer: Timer?
    
    deinit {
        selectorTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // ❌ 错误做法：导致循环引用
        // selectorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        // ✅ 正确做法：使用 Block API 并捕获 weak self
        selectorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        print("执行⏱️")
    }
    

}
