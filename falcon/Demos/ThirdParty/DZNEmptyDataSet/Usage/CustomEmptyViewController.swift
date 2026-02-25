//
//  CustomEmptyViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/25.
//

import Foundation
import UIKit

class CustomEmptyViewController: UIViewController {
    
    
    override func viewDidLoad() {
        view.backgroundColor  = .white
        self.md_hideNavigationBar = true
        self.view.showEmptyView()
    }
}
