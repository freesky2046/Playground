//
//  UsageTimerViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import UIKit

class UsageTimerViewController: UIViewController {
    weak var selectorTimer: Timer?
    var blockTimer: Timer?
    
    deinit {
//        selectorTimer?.invalidate()
        blockTimer?.invalidate()
        print("我成功释放了")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // ❌ 错误做法：导致循环引用,
        // RunLoop-->selectorTimer<-->self
        // 想断开 selectorTimer?.invalidate()这条线,没用.因为selectorTimer强引用了self,根本走不到deinit这里来
//       selectorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        // ✅ 正确做法：使用 Block API 并捕获 weak self
        blockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            print("执行block ⏱️")
        }
    }
    
    @objc func timerAction() {
        print("执行selector ⏱️")
    }
    


}
