//
//  TextLayoutDemoViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/19.
//

import UIKit
import SnapKit
import YYText

class YYTextAttributeViewController: UIViewController {
    var dataList: [String] = ["我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字我是第一行文字", "我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字我是第二行文字", "我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字我是第三行文字"]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(LayoutCell.self, forCellReuseIdentifier: NSStringFromClass(LayoutCell.self))
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

extension YYTextAttributeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutCell.calculateHeight(item: dataList[indexPath.row])
    }
}

extension YYTextAttributeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LayoutCell.self), for: indexPath) as! LayoutCell
        cell.config(item: dataList[indexPath.row])
        return cell
    }
    
    
}


class LayoutCell: UITableViewCell {
    lazy var label: YYLabel = YYLabel()
    
    static func calculateHeight(item: String) -> CGFloat {
        var container = YYTextContainer(size: CGSize(width: UIScreen.main.bounds.size.width, height: .greatestFiniteMagnitude))
        container.maximumNumberOfRows = 0
        var textlayout = YYTextLayout(container: container, text: attributeString(item: item))
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
        label.numberOfLines = 0
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(item: String) {
        label.attributedText = Self.attributeString(item: item)
    }
    
    
}
