//
//  HomeViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

class CacheViewController: UIViewController {
    var dataList: [String] = [
        "Basic",
        "Usage",
        "Imitate",
        "Unsafe"
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(100.0)
        }
    }

}

extension CacheViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = dataList[indexPath.row]
        switch title {
        case "Basic":
            let basic = CacheBasicViewController()
            navigationController?.pushViewController(basic, animated: true)
        case "Usage":
            let usage = CacheUsageViewController()
            navigationController?.pushViewController(usage, animated: true)
        case "Imitate":
            let imitate = CacheImitateViewController()
            navigationController?.pushViewController(imitate, animated: true)
        case "Unsafe":
            let unsafe = ThreadUnsafeDemoViewController()
            navigationController?.pushViewController(unsafe, animated: true)
        default:
            break
        }
    }
}

extension CacheViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
