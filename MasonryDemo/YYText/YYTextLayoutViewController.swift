//
//  TextLayoutDemoViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/19.
//

import UIKit
import SnapKit
import YYText

class YYTextLayoutViewController: UIViewController {
    var dataList: [LayoutModel] = [
        LayoutModel(item: "我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", layout: nil),
        LayoutModel(item: "我是第二行文字我是第二行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", layout: nil),
        LayoutModel(item: "我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", layout: nil),
        LayoutModel(item: "我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", layout: nil),
        LayoutModel(item: "我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", layout: nil)
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(TextLayoutCell.self, forCellReuseIdentifier: NSStringFromClass(TextLayoutCell.self))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }

}

extension YYTextLayoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        TextLayoutCell.calculateHeight(item: dataList[indexPath.row])
    }
}

extension YYTextLayoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextLayoutCell.self), for: indexPath) as! TextLayoutCell
        cell.config(item: dataList[indexPath.row])
        return cell
    }
    
    
}


class TextLayoutCell: UITableViewCell {
    lazy var label: YYLabel = YYLabel()
    
    static func calculateHeight(item: LayoutModel) -> CGFloat {
        // 生成一杯水(textlayout) ,需要杯子(container)和水(attributeString)
        // 高度用textBoundingSize
        
        var container = YYTextContainer(size: CGSize(width: UIScreen.main.bounds.size.width, height: .greatestFiniteMagnitude))
        container.maximumNumberOfRows = 0
        var textlayout = YYTextLayout(container: container, text: attributeString(item: item.item))
        item.layout = textlayout
        let height = textlayout?.textBoundingSize.height ?? 0
        
        return height
    }

    static private func attributeString(item: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: item)
        attributedText.yy_color = UIColor.red
        attributedText.yy_font = UIFont.systemFont(ofSize: 16.0)
        attributedText.yy_lineSpacing = 10.0
        return attributedText
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.top.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(item: LayoutModel) {
        /// 千万不要再用
        /// label.attributeString = "...."
        label.textLayout = item.layout
    }
    
    
}


class LayoutModel {
    var item: String = ""
    var layout: YYTextLayout?
    
    init(item: String, layout: YYTextLayout? = nil) {
        self.item = item
        self.layout = layout
    }
}
