//
//  ViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/15.
//

import UIKit
import YYText
import SnapKit

extension YYTextController: RouteCompatible {
    
}

class YYTextController: UIViewController {
    
    lazy var label: YYLabel = YYLabel()
    lazy var label2: YYLabel = YYLabel()
    lazy var label3: YYLabel = YYLabel()
    lazy var label4: YYLabel = YYLabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        
        view.addSubview(label)
        label.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 44)
        label.backgroundColor = UIColor.brown
        label.textVerticalAlignment = .bottom /// 支持垂直方向位置排布
        label.text = "我思故我在"
        

        view.addSubview(label2)
        /// 自动布局要加上这个属性
        label2.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width
        label2.textVerticalAlignment = .center
        label2.numberOfLines = 4
        label2.lineBreakMode = .byTruncatingTail
        let head = NSMutableAttributedString(string: "123456789123456789123456789123456789123456789123456789")
        head.yy_color = UIColor.blue
        head.yy_font = UIFont.systemFont(ofSize: 20.0)
        head.yy_setColor(UIColor.blue, range: head.yy_rangeOfAll())
        
        /// 实现高亮和交互点击
        let tail = NSMutableAttributedString(string: "#张三#")
        let highlight = YYTextHighlight()
        highlight.setColor(UIColor.brown)
        highlight.tapAction = { containerView, text, range, rect in
        }
        highlight.longPressAction = { containerView, text, range, rect in
        }
        tail.yy_setTextHighlight(highlight, range: tail.yy_rangeOfAll())
        tail.yy_color = UIColor.red
        tail.yy_backgroundColor = UIColor.clear
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(head)
        attributedText.append(tail)
        
        
        label2.attributedText = attributedText
        
        label2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(305)
            make.left.right.equalToSuperview()
        }
        
        label3.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width
        label3.numberOfLines = 1
        view.addSubview(label3)
        
        let attributedText3 = NSMutableAttributedString()
        
        let text = NSMutableAttributedString(string: "12345678910")
        
        text.yy_font = UIFont.systemFont(ofSize: 20)

        attributedText3.append(text)
        let text2 = NSMutableAttributedString(string: "111218111218111218111218111218111218111218111218111218111218111218")
        text2.yy_font = UIFont.systemFont(ofSize: 20)
        attributedText3.append(text2)
        label3.attributedText = attributedText3
        
        label3.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(505)
            make.left.right.equalToSuperview()
        }
        let imageView = UIImageView(image: UIImage(named: "img"))
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        /// 如果是token交互点击不能使用highlight,因为hightlight 算的时候不包括innerText
        let attachment = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .scaleAspectFit, attachmentSize: CGSize(width: 20, height: 20), alignTo: UIFont.systemFont(ofSize: 20), alignment: .center)
        label3.truncationToken = attachment
        label3.textTapAction = { containerView, text, range, rect in
            if let  truncationLine = (containerView as! YYLabel).textLayout?.truncatedLine {
                let tokenRect = CGRect(x: truncationLine.left + truncationLine.width - 25,
                                          y: truncationLine.top,
                                          width: 25,
                                          height: truncationLine.height)
                if tokenRect.intersects(rect) {
                    print("点击token")
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let textLayoutViewController = YYTextLayoutViewController()
        self.navigationController?.pushViewController(textLayoutViewController, animated: true)
    }
}
