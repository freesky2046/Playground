//
//  LoginUtil.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/30.
//

import Foundation
import UIKit


struct LoginUtil {
    
    func login() {
        if UIViewController.current is LoginViewController {
           return
        }

        let login = LoginViewController()
        let nav = UINavigationController(rootViewController: login)
        UIViewController.current?.present(nav, animated: true)
    }   
}
