//
//  TestAutolayoutViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/12.
//

import Foundation
import UIKit
import SnapKit

class TestAutolayoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        md_hideNavigationBar = true
        intrinsicContentSize()
    }
    
    
    // 系统会添加优先级
    func intrinsicContentSize() {
        let label = UILabel()
        label.text = "我是一行文字"
        let h = label.contentHuggingPriority(for: .vertical)
        let r = label.contentCompressionResistancePriority(for: .vertical)
        
        print("默认 Content Hugging Priority (垂平): \(h.rawValue)")
        print("默认 Content Compression Resistance Priority (垂平): \(r.rawValue)")
    }
    
    func priorityValue() {
        
    
        
    }
}
