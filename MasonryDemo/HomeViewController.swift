//
//  HomeViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

class HomeViewController: UIViewController {
    var dataList: [String] = [
        "YYText",
        "Alamofire",
        "Router",
        "UIKitExtension",
        "ThirdParty",
        "Namespace"
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(100.0)
        }
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let yytext = YYTextController()
            navigationController?.pushViewController(yytext, animated: true)
        case 1:
            let alamofire = AlamofireViewController()
            navigationController?.pushViewController(alamofire, animated: true)
        case 2:
            let router = RouterViewController()
            navigationController?.pushViewController(router, animated: true)
        default:
            break
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
