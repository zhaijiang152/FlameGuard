//
//  EmergencyViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/18.
//

import UIKit
import SnapKit

class EmergencyViewController: UIViewController, UIScrollViewDelegate {

    private let titles = ["AI识别", "AR逃生"]
    private var pageContainers: [UIView] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupPages()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentedControl.selectedSegmentIndex = 0
    }
    // MARK: - Setup
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(backgroundView)
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
    }

    private func setupLayout() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(36)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupPages() {
        let pages = [
            modelViewController(),
            ARescapeViewController(),
        ]
        
        //保证 scrollView 的触摸不会屏蔽子视图
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = false
        
        //创建一个 contentView，用来承载所有子控制器的视图
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // 与 scrollView 四边对齐
            make.height.equalTo(scrollView.snp.height) // 高度与 scrollView 一致（分页）
        }
        
        var previousView: UIView? = nil
        
        for vc in pages {
            addChild(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
            
            vc.view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(view)  // 每页宽度与屏幕一致
                
                if let previous = previousView {
                    make.leading.equalTo(previous.snp.trailing)  // 依次排在右边
                } else {
                    make.leading.equalToSuperview()  // 第一页贴左
                }
            }
            
            previousView = vc.view
        }
        
        // 让 contentView 的尾部与最后一页对齐
        if let last = previousView {
            contentView.snp.makeConstraints { make in
                make.trailing.equalTo(last.snp.trailing)
            }
        }
    }

    
//    private func setupPages() {
//        let pages = [
//            modelViewController(),
//            ARescapeViewController(),
//        ]
//
//        for (index, vc) in pages.enumerated() {
//            addChild(vc)
//            scrollView.addSubview(vc.view)
//            vc.didMove(toParent: self)
//
//            vc.view.snp.makeConstraints { make in
//                make.top.bottom.equalToSuperview()
//                make.width.equalTo(view)
//                make.leading.equalToSuperview().offset(CGFloat(index) * view.bounds.width)
//            }
//        }
//        scrollView.contentSize = CGSize(width: CGFloat(pages.count) * view.bounds.width,
//                                        height: 0)
//    }
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let offset = CGPoint(x: CGFloat(index) * view.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / view.bounds.width)
        segmentedControl.selectedSegmentIndex = pageIndex
    }
    // MARK: - UI Components
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        return scrollView
    }()
    
    lazy var segmentedControl:UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .segment_redcolor
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
}


