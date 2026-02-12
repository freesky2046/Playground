//
//  falconWrapper.swift
//  falcon
//
//  Created by 周明 on 2026/2/6.
//

import Foundation
import UIKit

// 1.定义命名空间包装器
// 这是一个轻量级的泛型结构体，它持有原始对象（Base）
struct falconWrapper<Base> {
    let base: Base
    init(base: Base) {
        self.base = base
    }
}

// 2.定义兼容协议并挂载 .kf 属性, 把 self 包裹进 KingfisherWrapper 中返回 。
public protocol falconCompatible: AnyObject { }

extension falconCompatible {
    var md: falconWrapper<Self> {
        return falconWrapper(base: self)
    }
}

// 3. 让系统类遵守协议
extension UIImageView: falconCompatible { }


// 4.这是最关键的一步。我们不在 UIImageView 上写方法，而是在 falconWrapper 上写方法，并限制泛型 Base 必须是 UIImageView 。
extension falconWrapper where Base: UIImageView {
    func setImage(with image: UIImage) {
           // 在这里，self 是 KingfisherWrapper
           // self.base 才是真正的 UIImageView
           let imageView = self.base
            imageView.image = image
           // ... 执行真正的下载和设置图片逻辑 ...
           print("正在给 \(imageView) 设置图片: image")
    }
}
