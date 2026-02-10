//
//  Navigationer.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit

class Navigationer {
    static func push(targetVCType: any RouteCompatible.Type, params: [String: String], animated: Bool) {
        if targetVCType.customNavigation(params: params) {
            return
        }
        let navigationController = UIViewController.current?.navigationController
        let targetVC = targetVCType.init()
        targetVC.handleParams(params: params)
        navigationController?.pushViewController(targetVC, animated: animated)
    }
    
    static func present(targetVCType: any RouteCompatible.Type, params: [String: String],animated: Bool) {

        if targetVCType.customNavigation(params: params) {
            return
        }
        let viewcontroller = UIViewController.current
        let targetVC = targetVCType.init()
        targetVC.handleParams(params: params)
        viewcontroller?.present(targetVC, animated: animated)
    }
    
    

 
}
