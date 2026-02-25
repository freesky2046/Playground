//
//  StackViewDemoViewController.swift
//  falcon
//
//  Created by falcon on 2026/02/25.
//

import UIKit
import SnapKit

class StackViewDemoViewController: UIViewController {

    // MARK: - Subject
    private lazy var subjectStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 8
        stack.backgroundColor = .systemGray6
        stack.layer.borderColor = UIColor.red.cgColor
        stack.layer.borderWidth = 1
        return stack
    }()
    
    // Subviews with different intrinsic sizes
    private lazy var item1Label: UILabel = {
        let label = UILabel()
        label.text = "Short"
        label.backgroundColor = .systemYellow.withAlphaComponent(0.6)
        label.layer.borderColor = UIColor.systemYellow.cgColor
        label.layer.borderWidth = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var item2Label: UILabel = {
        let label = UILabel()
        label.text = "Medium Text Content"
        label.backgroundColor = .systemGreen.withAlphaComponent(0.6)
        label.layer.borderColor = UIColor.systemGreen.cgColor
        label.layer.borderWidth = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var item3View: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.6)
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 1
        
        let label = UILabel()
        label.text = "Box\n(60x60)"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(60)//.priority(.high) // Intrinsic size simulation
        }
        return view
    }()
    
    // MARK: - Constraints Control
    private var subjectWidthConstraint: Constraint?
    private var subjectHeightConstraint: Constraint?
    
    // MARK: - Controls UI
    private let scrollView = UIScrollView()
    private let controlsStack = UIStackView()
    
    // Keep reference to update titles/state
    private var alignmentSegmentedControl: UISegmentedControl!
    private var axisSegmentedControl: UISegmentedControl!
    private var distributionSegmentedControl: UISegmentedControl!
    private var spacingSlider: UISlider!
    private var constraintWidthSwitch: UISwitch!
    private var constraintHeightSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "StackView Lab"
        view.backgroundColor = .white
        
        setupUI()
        setupControls()
        
        // Initial State
        updateAlignmentOptions()
    }
    
    private func setupUI() {
        // 1. Subject Area
        view.addSubview(subjectStackView)
        
        subjectStackView.addArrangedSubview(item1Label)
        subjectStackView.addArrangedSubview(item2Label)
        subjectStackView.addArrangedSubview(item3View)
        
        // Initial constraints (Intrinsic size mode)
        subjectStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            // Optional max width to keep it on screen
            make.width.lessThanOrEqualToSuperview().inset(20)
            
            // Prepare constraints for "Fixed Size" mode
            self.subjectWidthConstraint = make.width.equalTo(300).constraint
            self.subjectHeightConstraint = make.height.equalTo(300).constraint
        }
        subjectWidthConstraint?.deactivate()
        subjectHeightConstraint?.deactivate()
        
        // 2. Controls Area
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(subjectStackView.snp.bottom).offset(40)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(controlsStack)
        controlsStack.axis = .vertical
        controlsStack.spacing = 20
        controlsStack.isLayoutMarginsRelativeArrangement = true
        controlsStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        
        controlsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupControls() {
        // 1. Axis Control
        axisSegmentedControl = createSegmentedControl(items: ["Horizontal", "Vertical"], selectedIndex: 0, action: #selector(axisChanged(_:)))
        addControl(title: "Axis (轴向)", control: axisSegmentedControl)
        
        // 2. Distribution Control
        distributionSegmentedControl = createSegmentedControl(items: ["Fill", "FillEqually", "FillProportionally", "EqualSpacing", "EqualCentering"], selectedIndex: 0, action: #selector(distributionChanged(_:)))
        addControl(title: "Distribution (主轴分布)", control: distributionSegmentedControl)
        
        // 3. Alignment Control
        // Titles will be updated dynamically based on Axis
        alignmentSegmentedControl = createSegmentedControl(items: ["Fill", "Top", "Center", "Bottom"], selectedIndex: 0, action: #selector(alignmentChanged(_:)))
        addControl(title: "Alignment (交叉轴对齐)", control: alignmentSegmentedControl)
        
        // 4. Spacing Control
        spacingSlider = UISlider()
        spacingSlider.minimumValue = 0
        spacingSlider.maximumValue = 50
        spacingSlider.value = 8
        spacingSlider.addTarget(self, action: #selector(spacingChanged(_:)), for: .valueChanged)
        addControl(title: "Spacing (间距): 8", control: spacingSlider)
        
        // 5. Constraints Mode
        let widthSwitch = UISwitch()
        widthSwitch.isOn = false
        widthSwitch.addTarget(self, action: #selector(widthConstraintChanged(_:)), for: .valueChanged)
        constraintWidthSwitch = widthSwitch
        addControl(title: "Fixed Width (固定宽: 300)", control: widthSwitch)
        
        let heightSwitch = UISwitch()
        heightSwitch.isOn = false
        heightSwitch.addTarget(self, action: #selector(heightConstraintChanged(_:)), for: .valueChanged)
        constraintHeightSwitch = heightSwitch
        addControl(title: "Fixed Height (固定高: 300)", control: heightSwitch)
        
        // 6. Reset
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("Reset Defaults", for: .normal)
        resetBtn.addTarget(self, action: #selector(reset), for: .touchUpInside)
        controlsStack.addArrangedSubview(resetBtn)
        
        // 7. Info Label
        let infoLabel = UILabel()
        infoLabel.text = "提示: 当 Axis = Horizontal 时，固定 Width 可以看 Distribution 效果；固定 Height 可以看 Alignment 效果。"
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = .gray
        infoLabel.numberOfLines = 0
        controlsStack.addArrangedSubview(infoLabel)
    }
    
    private func addControl(title: String, control: UIView) {
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 14)
        
        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        
        controlsStack.addArrangedSubview(stack)
    }
    
    private func createSegmentedControl(items: [String], selectedIndex: Int, action: Selector) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = selectedIndex
        sc.addTarget(self, action: action, for: .valueChanged)
        return sc
    }
    
    // MARK: - Actions
    
    @objc private func axisChanged(_ sender: UISegmentedControl) {
        subjectStackView.axis = sender.selectedSegmentIndex == 0 ? .horizontal : .vertical
        updateAlignmentOptions()
        
        // Re-apply alignment because .top (Horizontal) != .leading (Vertical) in enum logic sometimes
        // But we want to preserve the "logic" (Start/Center/End)
        applyAlignment(index: alignmentSegmentedControl.selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateAlignmentOptions() {
        let isHorizontal = subjectStackView.axis == .horizontal
        if isHorizontal {
            alignmentSegmentedControl.setTitle("Fill", forSegmentAt: 0)
            alignmentSegmentedControl.setTitle("Top", forSegmentAt: 1)
            alignmentSegmentedControl.setTitle("Center", forSegmentAt: 2)
            alignmentSegmentedControl.setTitle("Bottom", forSegmentAt: 3)
        } else {
            alignmentSegmentedControl.setTitle("Fill", forSegmentAt: 0)
            alignmentSegmentedControl.setTitle("Leading", forSegmentAt: 1)
            alignmentSegmentedControl.setTitle("Center", forSegmentAt: 2)
            alignmentSegmentedControl.setTitle("Trailing", forSegmentAt: 3)
        }
    }
    
    @objc private func distributionChanged(_ sender: UISegmentedControl) {
        let distributions: [UIStackView.Distribution] = [.fill, .fillEqually, .fillProportionally, .equalSpacing, .equalCentering]
        subjectStackView.distribution = distributions[sender.selectedSegmentIndex]
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func alignmentChanged(_ sender: UISegmentedControl) {
        applyAlignment(index: sender.selectedSegmentIndex)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func applyAlignment(index: Int) {
        let axis = subjectStackView.axis
        // Index mapping:
        // 0: Fill
        // 1: Start (Top / Leading)
        // 2: Center
        // 3: End (Bottom / Trailing)
        
        switch index {
        case 0:
            subjectStackView.alignment = .fill
        case 1:
            subjectStackView.alignment = (axis == .horizontal) ? .top : .leading
        case 2:
            subjectStackView.alignment = .center
        case 3:
            subjectStackView.alignment = (axis == .horizontal) ? .bottom : .trailing
        default:
            break
        }
    }
    
    @objc private func spacingChanged(_ sender: UISlider) {
        subjectStackView.spacing = CGFloat(sender.value)
        // Update label text
        if let stack = sender.superview as? UIStackView, let label = stack.arrangedSubviews.first as? UILabel {
            label.text = String(format: "Spacing (间距): %.1f", sender.value)
        }
    }
    
    @objc private func widthConstraintChanged(_ sender: UISwitch) {
        if sender.isOn {
            subjectWidthConstraint?.activate()
        } else {
            subjectWidthConstraint?.deactivate()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func heightConstraintChanged(_ sender: UISwitch) {
        if sender.isOn {
            subjectHeightConstraint?.activate()
        } else {
            subjectHeightConstraint?.deactivate()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func reset() {
        axisSegmentedControl.selectedSegmentIndex = 0
        distributionSegmentedControl.selectedSegmentIndex = 0
        alignmentSegmentedControl.selectedSegmentIndex = 0
        spacingSlider.value = 8
        constraintWidthSwitch.isOn = false
        constraintHeightSwitch.isOn = false
        
        // Trigger updates
        axisChanged(axisSegmentedControl)
        distributionChanged(distributionSegmentedControl)
        alignmentChanged(alignmentSegmentedControl)
        spacingChanged(spacingSlider)
        widthConstraintChanged(constraintWidthSwitch)
        heightConstraintChanged(constraintHeightSwitch)
    }
}
