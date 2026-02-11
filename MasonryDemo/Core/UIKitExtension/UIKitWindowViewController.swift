//
//  UIKitWindowViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/28.
//

import UIKit

class UIKitWindowViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        let window = UIWindow.keywindow
        print("1:window\(window)")
        
        let current = UIViewController.current
        /// 当前已经变成自己了
        print("2:current\(current)")
         
        print("3:self\(self)")
        /// 取不到
        print("4:view.widow\(self.view.window)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 此时才能通过view.window取到window
        print("5:viewDidAppear view.widow\(self.view.window)")

    }
}
