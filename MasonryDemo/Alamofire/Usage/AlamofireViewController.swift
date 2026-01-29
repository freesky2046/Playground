import UIKit
import SnapKit

class AlamofireViewController: UIViewController {
    var dataList: [String] = [
        "第零阶段:基础知识",
        "第一阶段:简单使用",
        "第二阶段:二次封装",
        "第三阶段:更多能力",
        "第四阶段:深入源码",
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

extension AlamofireViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let zero = AlamofireZeroViewController()
            navigationController?.pushViewController(zero, animated: true)
        case 1:
            let first = AlamofireFirstViewController()
            navigationController?.pushViewController(first, animated: true)
        case 2:
            let second = AlamofireSecondViewController()
            navigationController?.pushViewController(second, animated: true)
        default:
            break
        }
    }
}

extension AlamofireViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
