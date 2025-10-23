////
////  ARescapeViewController.swift
////  FlameGuard
////
////  Created by 陈爽 on 2025/10/19.
////
//import UIKit
//import SnapKit
//import SwiftUI
//
//class ARescapeViewController: UIViewController {
//    
//    private let titleLabel = UILabel()
//    private let subtitleLabel = UILabel()
//    private let obstacleButton = UIButton()
//    private let pathButton = UIButton()
//    private let backgroundImageView = UIImageView()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupLayout()
//    }
//    
//    private func setupUI() {
//        
//        subtitleLabel.text = "选择功能，帮助你在危险中安全逃生"
//        subtitleLabel.textColor = .black
//        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        subtitleLabel.textAlignment = .center
//        subtitleLabel.numberOfLines = 2
//        view.addSubview(subtitleLabel)
//        view.addSubview(headerImageView)
//        
//        setupCardButton(obstacleButton,
//                        title: "障碍检测",
//                        icon: "viewfinder",
//                        color: UIColor.systemRed,
//                        description: "1.举起手机环顾四周，系统将自动识别前方障碍。\n2.语音提示会引导你避开危险区域。")
//
//        setupCardButton(pathButton,
//                        title: "逃生路径",
//                        icon: "map.fill",
//                        color: UIColor.systemGreen,
//                        description: "1.添加记录逃生路径。\n2.选择对应的逃生路径，系统将为您提供导航")
//    }
//    
//    private func setupCardButton(_ button: UIButton,
//                                 title: String,
//                                 icon: String,
//                                 color: UIColor,
//                                 description: String) {
//        button.subviews.forEach { $0.removeFromSuperview() }
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            color.withAlphaComponent(0.9).cgColor,
//            color.withAlphaComponent(0.6).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.cornerRadius = 24
//        gradientLayer.isGeometryFlipped = false
//        gradientLayer.masksToBounds = true
//        gradientLayer.isOpaque = false
//        gradientLayer.zPosition = -1 // 确保在最底层
//        
//        button.layer.insertSublayer(gradientLayer, at: 0)
//        button.layer.cornerRadius = 24
//        button.clipsToBounds = true
//        button.layer.shadowColor = color.cgColor
//        button.layer.shadowOpacity = 0.3
//        button.layer.shadowRadius = 10
//        button.layer.shadowOffset = CGSize(width: 100, height: 6)
//
//        let iconView = UIImageView(image: UIImage(systemName: icon))
//        iconView.tintColor = .white
//        iconView.contentMode = .scaleAspectFit
//        button.addSubview(iconView)
//
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.textColor = .white
//        titleLabel.font = .boldSystemFont(ofSize: 22)
//        button.addSubview(titleLabel)
//
//        let descLabel = UILabel()
//        descLabel.text = description
//        descLabel.textColor = .white.withAlphaComponent(0.9)
//        descLabel.font = .systemFont(ofSize: 16)
//        descLabel.numberOfLines = 0
//        button.addSubview(descLabel)
//
//        iconView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(16)
//            make.centerX.equalToSuperview()
//            make.height.width.equalTo(40)
//        }
//
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(iconView.snp.bottom).offset(12)
//            make.centerX.equalToSuperview()
//        }
//
//        descLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(12)
//            make.centerX.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(20)
//        }
//
//        if title == "障碍检测" {
//            button.addTarget(self, action: #selector(openObstacleDetection), for: .touchUpInside)
//        } else {
//            button.addTarget(self, action: #selector(openEscapePath), for: .touchUpInside)
//        }
//
//        
//        view.addSubview(button)
//        button.layoutIfNeeded()
//        DispatchQueue.main.async {
//            gradientLayer.frame = button.bounds
//        }
//    }
//    
//    private func setupLayout() {
//        headerImageView.snp.remakeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.6)
//            make.height.equalTo(80)
//        }
//        
//        subtitleLabel.snp.makeConstraints { make in
//            make.top.equalTo(headerImageView.snp.bottom).offset(16)
//            make.leading.trailing.equalToSuperview().inset(30)
//        }
//        
//        obstacleButton.snp.makeConstraints { make in
//            make.top.equalTo(subtitleLabel.snp.bottom).offset(60)
//            make.centerX.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(32)
//            make.height.equalTo(200)
//        }
//        
//        pathButton.snp.makeConstraints { make in
//            make.top.equalTo(obstacleButton.snp.bottom).offset(30)
//            make.centerX.equalToSuperview()
//            make.width.height.equalTo(obstacleButton)
//        }
//    }
//    // MARK: - UI Components
//    private lazy var headerImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(named: "逃生导航")
//        iv.contentMode = .scaleAspectFit
//        iv.clipsToBounds = true
//        return iv
//    }()
//    
//    // MARK: - Actions
//    @objc private func openObstacleDetection() {
//        let vc = DetectContentView()
//        let hostingVC = UIHostingController(rootView: vc)
//        hostingVC.modalPresentationStyle = .fullScreen
//        self.present(hostingVC, animated: true)
//    }
//    
//    @objc private func openEscapePath() {
//        let vc = ContentView()
//        let hostingVC = UIHostingController(rootView: vc)
//        hostingVC.modalPresentationStyle = .custom
//        self.present(hostingVC, animated: true)
//    }
//}

//
//  ARescapeViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/19.
//

import UIKit
import SnapKit
import SwiftUI

// ✅ 自定义 UIButton，带 gradient
class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    init(colors: [UIColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = 24
        clipsToBounds = true
        
        // 阴影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

class ARescapeViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "逃生导航")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let subtitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "选择功能，帮助你在危险中安全逃生"
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    private lazy var obstacleButton: GradientButton = {
        let btn = GradientButton(colors: [UIColor.systemRed.withAlphaComponent(0.9),
                                          UIColor.systemRed.withAlphaComponent(0.6)])
        setupButtonContent(btn,
                           title: "障碍检测",
                           icon: "viewfinder",
                           description: "1.举起手机环顾四周，系统将自动识别前方障碍。\n2.语音提示会引导你避开危险区域",
                           action: #selector(openObstacleDetection))
        return btn
    }()
    
    private lazy var pathButton: GradientButton = {
        let btn = GradientButton(colors: [UIColor.systemGreen.withAlphaComponent(0.9),
                                          UIColor.systemGreen.withAlphaComponent(0.6)])
        setupButtonContent(btn,
                           title: "逃生路径",
                           icon: "map.fill",
                           description: "1.添加记录逃生路径。\n2.选择对应的逃生路径，系统将为您提供导航",
                           action: #selector(openEscapePath))
        return btn
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(headerImageView)
        view.addSubview(subtitleLabel)
        view.addSubview(obstacleButton)
        view.addSubview(pathButton)
    }
    
    private func setupButtonContent(_ button: GradientButton,
                                    title: String,
                                    icon: String,
                                    description: String,
                                    action: Selector) {
        button.subviews.forEach { $0.removeFromSuperview() }
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        button.addSubview(iconView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        button.addSubview(titleLabel)
        
        // Description
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        button.addSubview(descLabel)
        
        // SnapKit Layout
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        headerImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(80)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        obstacleButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(200)
        }
        
        pathButton.snp.makeConstraints { make in
            make.top.equalTo(obstacleButton.snp.bottom).offset(30)
            make.leading.trailing.equalTo(obstacleButton)
            make.height.equalTo(obstacleButton)
        }
    }
    
    // MARK: - Actions
    @objc private func openObstacleDetection() {
        let vc = DetectContentView()
        let hostingVC = UIHostingController(rootView: vc)
        hostingVC.modalPresentationStyle = .fullScreen
        self.present(hostingVC, animated: true)
    }
    
    @objc private func openEscapePath() {
        let vc = ContentView()
        let hostingVC = UIHostingController(rootView: vc)
        hostingVC.modalPresentationStyle = .fullScreen
        self.present(hostingVC, animated: true)
    }
}
