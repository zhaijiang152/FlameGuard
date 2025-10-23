//
//  MineViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/19.
//

import UIKit
import SnapKit

class MineViewController: UIViewController {

    let seconItems : [SetItem] = [SetItem(iconName: "newsInform", title: "消息通知"),SetItem(iconName: "emergencyPeople", title: "紧急联系人"),SetItem(iconName: "homeInfo", title: "家庭信息")]
    let bottomItems: [SetItem] = [SetItem(iconName: "mySets", title: "我的设置"),SetItem(iconName: "helpCenter", title: "帮助中心"),SetItem(iconName: "aboutUs", title: "关于我们")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let profile = UserDataManager.shared.loadUserProfile()
        nicknameLabel.text = profile.name
        if let data = profile.avatarData {
            avatarImageView.image = UIImage(data: data)
        }else{
            avatarImageView.image = UIImage(named: "InitialAvatar")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = 32
        avatarImageView.clipsToBounds = true
    }
    
    private func setupNav(){
        self.title = "个人中心"
    }
    
    private func setupUI() {
        topView.addSubview(avatarImageView)
        topView.addSubview(nicknameLabel)
        topView.addSubview(editBtn)

        view.addSubview(backgroundView)
        view.addSubview(topView)
        view.addSubview(secondCView)
        view.addSubview(bottomCView)
    }

    private func setupLayout() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.height.width.equalTo(64)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(20)
        }
        editBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        secondCView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(260)
        }
        
        bottomCView.snp.makeConstraints { make in
            make.top.equalTo(secondCView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(260)
        }
    }

    // MARK: - Actions
    @objc func clickEditBtn(){
        let view = ModifyViewController()
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    // MARK: - UI Components
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var topView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var avatarImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private var nicknameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var editBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.addTarget(self, action: #selector(clickEditBtn), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondCView:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 5
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        let title = UILabel()
        title.text = "基础设置"
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .left
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        let cv = SetCollectionView(items: seconItems)
        view.addSubview(cv)
        cv.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        return view
    }()
    
    private lazy var bottomCView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 5
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        let title = UILabel()
        title.text = "其他设置"
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .left
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        let cv = SetCollectionView(items: bottomItems)
        view.addSubview(cv)
        cv.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        return view
    }()
}
