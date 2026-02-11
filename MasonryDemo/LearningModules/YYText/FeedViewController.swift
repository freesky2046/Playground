import UIKit
import YYText
import SnapKit

// MARK: - 1. FeedLayout (排版模型)
// 核心思想：把所有 UI 的 Frame、Layout、Height 全部在后台算好存这里
// 视图层 (Cell) 只负责从这里取值，不做任何计算
class FeedLayout {
    // 原始数据
    let model: FeedModel
    
    // --- 预计算的布局结果 (全部是 UI 属性) ---
    var avatarFrame: CGRect = .zero
    var nameFrame: CGRect = .zero
    var contentLayout: YYTextLayout? // 文字排版
    var contentFrame: CGRect = .zero
    var imageFrame: CGRect = .zero
    var cellHeight: CGFloat = 0
    
    // 模拟图片 URL (实际项目中来自 Model)
    let avatarURL = URL(string: "https://via.placeholder.com/40")
    let imageURL = URL(string: "https://via.placeholder.com/300x200")
    
    init(model: FeedModel) {
        self.model = model
    }
    
    // 核心：在后台线程执行这个方法
    func layout() {
        let screenWidth = UIScreen.main.bounds.width
        let leftPadding: CGFloat = 15
        let topPadding: CGFloat = 15
        
        // 1. 算头像 Frame (固定大小)
        avatarFrame = CGRect(x: leftPadding, y: topPadding, width: 40, height: 40)
        
        // 2. 算昵称 Frame
        // 简单文本算 Frame 比 CoreText 快，直接用 NSString 方法
        let nameText = "用户 \(model.id)" as NSString
        let nameSize = nameText.size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        nameFrame = CGRect(x: avatarFrame.maxX + 10, y: topPadding + 2, width: nameSize.width, height: nameSize.height)
        
        // 3. 算正文 Layout (YYText)
        let contentWidth = screenWidth - leftPadding * 2
        let container = YYTextContainer(size: CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        container.maximumNumberOfRows = 0
        
        let text = NSMutableAttributedString(string: model.content)
        text.yy_font = UIFont.systemFont(ofSize: 16)
        text.yy_lineSpacing = 4
        text.yy_color = .black
        
        if let layout = YYTextLayout(container: container, text: text) {
            self.contentLayout = layout
            // 确定正文 Frame
            let textHeight = layout.textBoundingSize.height
            contentFrame = CGRect(x: leftPadding, y: avatarFrame.maxY + 10, width: contentWidth, height: textHeight)
        }
        
        // 4. 算配图 Frame (假设有图)
        // 实际开发中根据图片宽高比算
        let imageHeight: CGFloat = 200
        imageFrame = CGRect(x: leftPadding, y: contentFrame.maxY + 10, width: 200, height: imageHeight)
        
        // 5. 算总高度
        cellHeight = imageFrame.maxY + 15 // 底部留白
    }
}

// 简单的原始数据模型
struct FeedModel {
    let id: Int
    let content: String
}

// MARK: - 2. ComplexFeedCell (纯 Frame 布局)
class ComplexFeedCell: UITableViewCell {
    
    // 所有的 View
    let avatarView = UIImageView()
    let nameLabel = UILabel()
    let contentLabel = YYLabel()
    let postImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        // 1. 初始化 View
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(postImageView)
        
        // 设置属性
        avatarView.backgroundColor = .lightGray
        avatarView.layer.cornerRadius = 20 // 注意：这里还是会离屏渲染，极致优化应使用圆角图片
        avatarView.layer.masksToBounds = true
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .darkGray
        
        contentLabel.displaysAsynchronously = true // 开启异步绘制
        contentLabel.ignoreCommonProperties = true
        
        postImageView.backgroundColor = .secondarySystemBackground
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 绑定 Layout (极速模式)
    func bind(layout: FeedLayout) {
        // 1. 直接设置 Frame (比 AutoLayout 快得多)
        avatarView.frame = layout.avatarFrame
        nameLabel.frame = layout.nameFrame
        contentLabel.frame = layout.contentFrame
        postImageView.frame = layout.imageFrame
        
        // 2. 赋值内容
        // 这里的图片加载建议配合 SDWebImage/YYWebImage
        // avatarView.sd_setImage(with: layout.avatarURL)
        nameLabel.text = "用户 \(layout.model.id)"
        
        // 3. 核心：直接赋值 Layout
        contentLabel.textLayout = layout.contentLayout
    }
}

// MARK: - 3. FeedViewController
class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    // 数据源变成了 Layout 数组，而不是 Model 数组
    var layouts: [FeedLayout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        loadData()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ComplexFeedCell.self, forCellReuseIdentifier: "ComplexFeedCell")
        view.addSubview(tableView)
    }
    
    func loadData() {
        print("开始加载数据...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 1. 模拟获取 Model 数据
            var newLayouts: [FeedLayout] = []
            
            for i in 0..<100 {
                let text = self.randomText(length: Int.random(in: 50...300))
                let model = FeedModel(id: i, content: text)
                
                // 2. 创建 Layout 对象
                let layout = FeedLayout(model: model)
                
                // 3. 【核心】在后台线程计算所有 Frame 和 TextLayout
                layout.layout()
                
                newLayouts.append(layout)
            }
            
            // 4. 回到主线程刷新
            DispatchQueue.main.async {
                self.layouts = newLayouts
                self.tableView.reloadData()
                print("UI 刷新完成")
            }
        }
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplexFeedCell", for: indexPath) as! ComplexFeedCell
        // 绑定 Layout
        cell.bind(layout: layouts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 直接返回算好的高度
        return layouts[indexPath.row].cellHeight
    }
    
    func randomText(length: Int) -> String {
        let base = "YYText 极致性能优化演示。抛弃 AutoLayout，使用 Frame 布局。把所有计算任务（排版、几何计算）全部放到后台线程。"
        var res = ""
        while res.count < length {
            res += base
        }
        return String(res.prefix(length))
    }
}
