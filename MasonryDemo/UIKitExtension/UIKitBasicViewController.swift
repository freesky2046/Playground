//
//  UIKitBasicViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/27.
//

import UIKit

class UIKitBasicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // MARK: - 用在集合上的高阶函数
        
        // 1.map
        let items = [1, 2, 3]
        // 转换后生成新的数组
        let items1 = items.map({ String($0)})
        print("map转换后非可选值类型:\(items1)")
        let item3 = [1, 2, 3, nil]
        print(item3)
        let items4 = item3.map({$0}) // 转换的是什么元素类型,输出的数组就是什么元素类型的集合
        print("map转换为可选值类型:\(items4)")
    
        // 2. flatmap:  用在拆包的时候优选 compactMap
        /// 作用1: 空过滤,转换,解包
        /// 作用2: 拍平多维数组 2纬-〉1纬
        let item5 = [1, 2, 3]
        
        let item6 = item5.flatMap({ String($0) }) // 转换的是非可选类型,和map效果一样
        print("转换后为非可选值类型,效果和map一样:\(item6)")
        let item7 = [1, 2, 3, nil]
        let item8 = item7.flatMap({$0})
        print("转换后为可选值类型,拆包再过滤:\(item8)")
        
        let item10 = [[1,2], [2,3], [4, 5]]
        let item11 = item10.flatMap { $0 }
        print("拍平元素:\(item11)")
        
        
        /// 验证是先过滤还是转换后过滤
        let ii = [nil, 1, 2]
        let res =  ii.flatMap({ _ in 2 })
        print("验证是先过滤还是后过滤\(res)")
        
        // 3.compactMap: 空过滤,转换,解包
        let item9 = item8.compactMap({$0})
        print("compactMap转换后为可选类型,拆包再过滤:\(item9)")
    
        // MARK: - 用在可选值上的高阶函数
        let value: Int? = nil
        // nil就直接返回nil,不会参与转换
        let result = value.flatMap({_ in 2 })
        print("map用于可选值: \(result)")
        
        let value2: Int? = 2
        // nil就直接返回nil,不会参与转换
        let result2 = value2.flatMap({_ in 2 })
        print("map用于可选值: \(result2)")
        
        
        
        
        
       
        
        
        
    }
    

}
