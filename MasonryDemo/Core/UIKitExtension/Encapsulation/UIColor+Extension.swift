//
//  UIColor+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/30.
//


import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        let r =  CGFloat(arc4random_uniform(255))
        let g =  CGFloat(arc4random_uniform(255))
        let b =  CGFloat(arc4random_uniform(255))
        return RGB(r: r, g: g, b: b)
    }
    
    static private func RGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
}
