//
//  AlamofireThirdViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/27.
//

import UIKit

class AlamofireThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        print("更多功能")
        print("1:可取消: NetworkManager外部调用方法返回值增加DataRequest")
        print("2.日志:NetworkLogger")
        print("3.多环境切换: 增加enum AppEnvironment 枚举")
        print("4.通用响应外壳: 将原来的T:Codable 换成一个BaseResponse<T>")
    }

}
