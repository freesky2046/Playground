//
//  DesignSystemListDetailDemoViewController.swift
//  MasonryDemo
//
//  Created by Trae on 2026/2/11.
//

import UIKit
import SnapKit

class DesignSystemListDetailDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.backgroundPrimary
        title = "List & Detail Typography"
        
        setupUI()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // MARK: - 1. List Style Simulation
        let section1 = DSLabel(text: "1. 列表样式 (List Style)", style: .h2)
        container.addSubview(section1)
        section1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.l)
            make.left.equalToSuperview().offset(DSSpacing.m)
        }
        
        // List Cell Simulation
        let cellView = UIView()
        cellView.backgroundColor = DSColor.backgroundSecondary
        cellView.layer.cornerRadius = DSSpacing.radiusMedium
        container.addSubview(cellView)
        cellView.snp.makeConstraints { make in
            make.top.equalTo(section1.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.height.equalTo(80)
        }
        
        let listTitle = DSLabel(text: "这里是列表标题 (List Title)", style: .listTitle)
        cellView.addSubview(listTitle)
        listTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DSSpacing.s)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
        }
        
        let listSubtitle = DSLabel(text: "这里是列表副标题或摘要信息，通常颜色较浅，字号较小。(List Subtitle)", style: .listSubtitle)
        cellView.addSubview(listSubtitle)
        listSubtitle.snp.makeConstraints { make in
            make.top.equalTo(listTitle.snp.bottom).offset(DSSpacing.xxs)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
        }
        
        // MARK: - 2. Detail Page Simulation
        let section2 = DSLabel(text: "2. 详情页样式 (Detail Style)", style: .h2)
        container.addSubview(section2)
        section2.snp.makeConstraints { make in
            make.top.equalTo(cellView.snp.bottom).offset(DSSpacing.xxl)
            make.left.equalToSuperview().offset(DSSpacing.m)
        }
        
        let detailContainer = UIView()
        detailContainer.backgroundColor = DSColor.backgroundPrimary // 详情页通常是纯色背景
        container.addSubview(detailContainer)
        detailContainer.snp.makeConstraints { make in
            make.top.equalTo(section2.snp.bottom).offset(DSSpacing.m)
            make.left.right.equalToSuperview().inset(DSSpacing.m)
            make.bottom.equalToSuperview().offset(-DSSpacing.xl)
        }
        
        let detailTitle = DSLabel(text: "这是一篇关于 Design System 的详情文章标题", style: .detailTitle)
        detailContainer.addSubview(detailTitle)
        detailTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        let detailMeta = DSLabel(text: "2026-02-11 · Trae AI", style: .caption)
        detailContainer.addSubview(detailMeta)
        detailMeta.snp.makeConstraints { make in
            make.top.equalTo(detailTitle.snp.bottom).offset(DSSpacing.s)
            make.left.right.equalToSuperview()
        }
        
        let longText = """
        在移动端应用开发中，详情页的排版至关重要。与列表页不同，详情页承载了大量的信息输入，因此阅读体验是第一优先级的。
        
        我们专门定义了 `.detailBody` 样式，它不仅仅是设置了字体大小，更重要的是它默认开启了舒适的行间距 (Line Spacing)。
        
        如果使用系统默认的 Label 样式，密集的文字会让用户感到压抑。而增加了 8pt 的行间距后，文字的呼吸感增强，阅读效率显著提高。这就是 Design System 在细节处的价值。
        """
        
        let detailBody = DSLabel(text: nil, style: .detailBody)
        detailBody.setText(longText) // 使用 setText 触发富文本样式
        detailContainer.addSubview(detailBody)
        detailBody.snp.makeConstraints { make in
            make.top.equalTo(detailMeta.snp.bottom).offset(DSSpacing.l)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
