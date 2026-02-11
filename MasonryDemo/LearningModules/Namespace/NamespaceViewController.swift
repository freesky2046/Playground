//
//  Usage.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation
import UIKit

class NamespaceViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let imageView = UIImageView()
        imageView.md.setImage(with: UIImage(named: "img")! )
        imageView.frame = CGRect(x: 0, y: 100, width: 40, height: 40)
        view.addSubview(imageView)
        
    }
}
