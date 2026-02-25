//
//  LayoutConstraintViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/24.
//

import Foundation
import UIKit

class LayoutConstraintViewController: UIViewController {
    
    lazy var redView: UIView = {
        let redView = UIView()
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.backgroundColor = UIColor.white
        return redView
    }()
    
    lazy var blueView: UIView = {
        let blueView = UIView()
        blueView.translatesAutoresizingMaskIntoConstraints = false
        blueView.backgroundColor = UIColor.blue
        return blueView
    }()
    
    lazy var yellowView: UIView = {
        let redView = UIView()
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.backgroundColor = UIColor.yellow
        return redView
    }()
    
    lazy var blackView: UIView = {
        let blueView = UIView()
        blueView.translatesAutoresizingMaskIntoConstraints = false
        blueView.backgroundColor = UIColor.black
        return blueView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBrown
        view.addSubview(redView)
        view.addSubview(blueView)
        setupNSLayoutConstraint()
        
        view.addSubview(yellowView)
        view.addSubview(blackView)
        setupVFLConstraint()
    }
    
    private func setupNSLayoutConstraint() {
        let constraint1 = NSLayoutConstraint(item: redView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraint2 = NSLayoutConstraint(item: redView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraint3 = NSLayoutConstraint(item: redView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        let constraint4 = NSLayoutConstraint(item: redView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        view.addConstraints([constraint1, constraint2, constraint3, constraint4])
        
        let constraint5 = NSLayoutConstraint(item: blueView, attribute: .top, relatedBy: .equal, toItem: self.redView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let constraint6 = NSLayoutConstraint(item: blueView, attribute: .left, relatedBy: .equal, toItem: self.redView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let constraint7 = NSLayoutConstraint(item: blueView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        let constraint8 = NSLayoutConstraint(item: blueView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        view.addConstraints([constraint5, constraint6, constraint7, constraint8])
    }
    
    private func setupVFLConstraint() {
        // H: 水平, V: 垂直
        // | 父视图
        
        // 和父视图直接添加约束
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[yellowView]-100-|", metrics: nil, views: ["yellowView":yellowView])
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[yellowView]-100-|", metrics: nil, views: ["yellowView":yellowView])
        self.view.addConstraints(constraints1)
        self.view.addConstraints(constraints2)
    
        
    }
    
}
