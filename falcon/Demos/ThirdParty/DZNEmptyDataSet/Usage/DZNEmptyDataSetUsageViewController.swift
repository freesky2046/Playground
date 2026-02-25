//
//  DZNEmptyDataSetUsageViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/11.
//

import UIKit
import DZNEmptyDataSet
import SnapKit

class DZNEmptyDataSetUsageViewController: UIViewController  {
    var dataList: [String] = []
    
    lazy var tableView: UITableView = {
        let tableview = UITableView(frame: .zero)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.emptyDataSetSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return tableview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.reloadData()
    }
}

extension DZNEmptyDataSetUsageViewController: UITableViewDelegate {
    
}

extension DZNEmptyDataSetUsageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        return cell
    }
    
}

extension DZNEmptyDataSetUsageViewController: DZNEmptyDataSetSource {

    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let view = UIView(frame: CGRectMake(0, 0, 200, 100))
        
        view.backgroundColor = .systemYellow
        
        let label = UILabel(frame: CGRect(x: 0, y: 80, width: 200, height: 40))
          label.text = "No Data Available"
          label.textAlignment = .center
          view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", metrics: nil, views: ["label": label]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", metrics: nil, views: ["label": label]))
        return view
    }
}
