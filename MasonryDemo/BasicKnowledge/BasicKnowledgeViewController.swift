//
//  HomeViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import YYText
import SnapKit

extension BasicKnowledgeViewController: RouteCompatible {
    static func customNavigation(params: [String : String]) -> Bool {
          if UserDefaults.standard.bool(forKey: "isLogin") == false {
              return false
          }
          return false
      }
      
      func handleParams(params: [String : String]) {
          param = Int(params["p"] ?? "") ?? 0
      }
}


class BasicKnowledgeViewController: UIViewController {
    
    var param: Int = 0
    
    var dataList: [String] = [
        "Queue",
        "Lock",
        "Timer",
        "AssociatedObject",
        "Navigation"
        
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
        self.md_hideNavigationBar = true
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(UIWindow.safeAreaInsets.top)
        }
  
    }

}

extension BasicKnowledgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = dataList[indexPath.row]
        
        switch title {
        case "Queue":
            let queue = QueueViewController()
            navigationController?.pushViewController(queue, animated: true)
        case "Lock":
            break
        case "Timer":
            let timer = UsageTimerViewController()
            navigationController?.pushViewController(timer, animated: true)
        case "AssociatedObject":
            let associatedObject = AssociatedObjectViewController()
            navigationController?.pushViewController(associatedObject, animated: true)
        case "Navigation":
            let controller: UseNavigationBarController = UseNavigationBarController()
            navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
}

extension BasicKnowledgeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
