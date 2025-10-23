//
//  ViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/18.
//

import UIKit
import SnapKit
import SDCycleScrollView
import SafariServices

class HomeViewController: UIViewController {

    let itemData: [[(bg: UIColor, icon: String, text: String)]] = [
        [(.quick_redcolor, "ai", "AI识隐患"),
         (.quick_yellowcolor, "fireCategory", "火灾分类"),
         (.quick_bluecolor, "equipment", "器材图解"),
         (.quick_greencolor, "example", "警示案例")],
        [(.quick_redcolor, "firemap", "消防地图"),
         (.quick_yellowcolor, "record", "每日一记"),
         (.quick_bluecolor, "arExtinguish", "AR灭火"),
         (.quick_greencolor, "exercise", "闯关答题"), ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupUI()
        setupLayout()
    }

    private func setupUI(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(backgroundView)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(bannerView)
        contentView.addSubview(quickStackView)
        contentView.addSubview(classroomTitleBar)
        contentView.addSubview(classroomHStack)
        contentView.addSubview(newsTitleBar)
        contentView.addSubview(newsCardsStackView)
    }
    
    private func setupLayout(){
        backgroundView.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints{ make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints{ make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        bannerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        quickStackView.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(168)
        }
        classroomTitleBar.snp.makeConstraints { make in
            make.top.equalTo(quickStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }
        classroomHStack.snp.makeConstraints { make in
            make.top.equalTo(classroomTitleBar.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(208)
        }
        newsTitleBar.snp.makeConstraints { make in
            make.top.equalTo(classroomHStack.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }
        newsCardsStackView.snp.makeConstraints { make in
            make.top.equalTo(newsTitleBar.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupTabBar() {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        tabBar.snp.makeConstraints{ make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        let homeItem = UITabBarItem(title: "首页", image: UIImage(named: "home"), tag: 0)
        let konwledgeItem = UITabBarItem(title: "知识", image: UIImage(named:"konwledge"), tag: 1)
        let emergencyItem = UITabBarItem(title: "应急", image: UIImage(named: "emergency"), tag: 2)
        let mineItem = UITabBarItem(title: "我的", image: UIImage(named: "mine"), tag: 3)

        tabBar.items = [homeItem, konwledgeItem, emergencyItem, mineItem]
        tabBar.selectedItem = homeItem
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    lazy var backgroundView : UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    //轮播图设置
    private let guideImages = ["guide1", "guide2","guide3","guide4"]
    private lazy var bannerView: SDCycleScrollView = {
        let cycleScrollView = SDCycleScrollView()
        cycleScrollView.localizationImageNamesGroup = guideImages
        cycleScrollView.autoScroll = true
        cycleScrollView.autoScrollTimeInterval = 3.0
        cycleScrollView.infiniteLoop = true
        cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
        cycleScrollView.showPageControl = true
        cycleScrollView.pageDotColor = UIColor.white
        cycleScrollView.currentPageDotColor = UIColor.gray
        cycleScrollView.layer.cornerRadius = 20
        cycleScrollView.clipsToBounds = true
        return cycleScrollView
    }()
    
    private lazy var quickStackView: UIStackView = {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 16

        for col in 0..<4 {
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.spacing = 16
            verticalStack.distribution = .fillEqually

            for row in 0..<2 {
                let data = itemData[row][col]
                let itemView = UIView()
                itemView.layer.cornerRadius = 12
                itemView.clipsToBounds = true
                
                let backView = UIView()
                backView.backgroundColor = data.bg
                backView.layer.cornerRadius = 12

                let iconView = UIImageView(image: UIImage(named: data.icon))
                iconView.contentMode = .scaleAspectFit

                let label = UILabel()
                label.text = data.text
                label.textColor = .black
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.textAlignment = .center

                itemView.addSubview(backView)
                backView.addSubview(iconView)
                itemView.addSubview(label)
                
                backView.snp.makeConstraints{ make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview()
                    make.width.height.equalTo(56)
                }
                iconView.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                }
                label.snp.makeConstraints { make in
                    make.top.equalTo(backView.snp.bottom).offset(4)
                    make.centerX.equalToSuperview()
                }
                verticalStack.addArrangedSubview(itemView)
            }
            horizontalStack.addArrangedSubview(verticalStack)
        }

        return horizontalStack
    }()
 
    private lazy var classroomTitleBar: UIStackView = {
        createSectionTitle(title: "消防微课堂", actionText: " ")
    }()
    
    private lazy var classroomHStack: UIStackView = {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 12
        let items = [
            ("fireGuide", "灭火器使用指南","正确使用灭火器，从提拉-瞄准开始"),
            ("escape", "火灾逃生技巧","掌握关键逃生要领，保护生命安全")
        ]
        for item in items {
            let v = createCourseCard(image: item.0, title: item.1 ,subtitle:item.2)
            hStack.addArrangedSubview(v)
        }
        return hStack
    }()
    
    private lazy var newsTitleBar: UIStackView = {
        createSectionTitle(title: "安全资讯", actionText: "更多 >>")
    }()
    
    private lazy var newsCardsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        let news = [
            ("news1", "某市消防安全管理创新现场会成功召开", "消防日报 2023-12-20"),
            ("news2", "全国消防安全专项整治行动取得阶段性成效", "安全时报 2023-12-19")
        ]
        view.addArrangedSubview(createNewsCard(image: news[0].0, title: news[0].1, subtitle: news[0].2))
        view.addArrangedSubview(createNewsCard(image: news[1].0, title: news[1].1, subtitle: news[1].2))
        return view
    }()
 
    @objc private func kpButtonTapped() {
        if let url = URL(string: "https://www.119.gov.cn/kp/hzyf/index.shtml") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            config.barCollapsingEnabled = true
            
            let safariVC = SFSafariViewController(url: url, configuration: config)
            safariVC.preferredControlTintColor = .systemBlue
            present(safariVC, animated: true)
        }
    }
}

extension HomeViewController{
    
    private func createSectionTitle(title: String, actionText: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fill
        row.alignment = .center
        row.spacing = 20
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let action = UIButton(type: .system)
        action.setTitle(actionText, for: .normal)
        action.setTitleColor(.systemBlue, for: .normal)
        action.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        action.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        action.addTarget(self, action: #selector(kpButtonTapped), for: .touchUpInside)
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(spacer)
        row.addArrangedSubview(action)
        return row
    }
    
    private func createCourseCard(image: String, title: String ,subtitle:String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = title
        label.textAlignment = .left
        label.numberOfLines = 1

        let subLabel = UILabel()
        subLabel.font = UIFont.systemFont(ofSize: 14)
        subLabel.textColor = .systemGray
        subLabel.text = subtitle
        subLabel.textAlignment = .left
        subLabel.numberOfLines = 2
        
        container.addSubview(imageView)
        container.addSubview(label)
        container.addSubview(subLabel)

        imageView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        label.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        subLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        return container
    }
    
    private func createNewsCard(image: String, title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        
        let img = UIImageView(image: UIImage(named: image))
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let row = UIStackView(arrangedSubviews: [img, textStack])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        container.addSubview(row)
        row.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        img.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(120)
        }
        return container
    }
    
}
