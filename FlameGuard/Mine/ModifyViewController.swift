//
//  ModifyViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/20.
//

import UIKit
import SnapKit

class ModifyViewController:UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        loadUserInfo()
        setupKeyboardDismissGesture()
    }
    
    private func setupUI(){
        self.title = "编辑个人信息"
        view.addSubview(backgroundView)
        
        topView.addSubview(avatarImageView)
        topView.addSubview(modifyButton)
        view.addSubview(topView)
        view.addSubview(secondView)
        view.addSubview(saveButton)
        
        secondView.addSubview(nameLabel)
        secondView.addSubview(nameTextField)
        secondView.addSubview(genderLabel)
        secondView.addSubview(genderStackView)
        genderStackView.addArrangedSubview(maleRadioButton)
        genderStackView.addArrangedSubview(maleLabel)
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        genderStackView.addArrangedSubview(spacer)
        
        genderStackView.addArrangedSubview(femaleRadioButton)
        genderStackView.addArrangedSubview(femaleLabel)
        secondView.addSubview(bioLabel)
        secondView.addSubview(bioTextView)

        nameLabel.text = "昵称"
        nameTextField.borderStyle = .roundedRect
        genderLabel.text = "性别"
        
        bioLabel.text = "个人简介"
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.lightGray.cgColor
        bioTextView.layer.cornerRadius = 8
    }
    
    private func setupLayout(){
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
            make.top.equalToSuperview().offset(20)
        }
        
        modifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        secondView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(topView.snp.bottom).offset(12)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(secondView.snp.top).offset(20)
            make.leading.equalTo(secondView.snp.leading).offset(16)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.equalTo(nameLabel)
        }

        genderStackView.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(10)
            make.leading.equalTo(nameLabel)
        }

        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(genderStackView.snp.bottom).offset(16)
            make.leading.equalTo(nameLabel)
        }

        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(secondView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.clipsToBounds = true
    }
    
    // MARK: - Gender Selection
    @objc private func selectMale() {
        maleRadioButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
        femaleRadioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        maleRadioButton.tintColor = .systemBlue
        femaleRadioButton.tintColor = .systemGray
    }

    @objc private func selectFemale() {
        femaleRadioButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
        maleRadioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        femaleRadioButton.tintColor = .systemPink
        maleRadioButton.tintColor = .systemGray
    }
    
    private func loadUserInfo() {
        let profile = UserDataManager.shared.loadUserProfile()
        nameTextField.text = profile.name
        bioTextView.text = profile.bio

        if profile.gender == "男" {
            selectMale()
        } else if profile.gender == "女" {
            selectFemale()
        }

        if let data = profile.avatarData, let image = UIImage(data: data) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "InitialAvatar")
        }
    }
    
    @objc func clickmodifyBtn() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc func clickSaveBtn() {
        let gender = maleRadioButton.tintColor == .systemBlue ? "男" : (femaleRadioButton.tintColor == .systemPink ? "女" : "未选择")

        let profile = UserProfile(
            name: nameTextField.text ?? "",
            gender: gender,
            bio: bioTextView.text ?? "",
            avatarData: avatarImageView.image?.pngData()
        )
        UserDataManager.shared.saveUserProfile(profile)
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    // MARK: - UI Components
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var avatarImageView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var modifyButton:UIButton = {
        let button = UIButton()
        button.setTitle("更换头像", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(clickmodifyBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var topView:UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var secondView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var saveButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "saveButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clickSaveBtn), for: .touchUpInside)
        return button
    }()

    lazy var nameLabel = UILabel()
    lazy var nameTextField = UITextField()
    lazy var genderLabel = UILabel()
    
    lazy var genderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()
    
    lazy var maleRadioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(selectMale), for: .touchUpInside)
        return button
    }()
    
    lazy var femaleRadioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(selectFemale), for: .touchUpInside)
        return button
    }()
    
    lazy var maleLabel: UILabel = {
        let label = UILabel()
        label.text = "男"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var femaleLabel: UILabel = {
        let label = UILabel()
        label.text = "女"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var bioLabel = UILabel()
    lazy var bioTextView = UITextView()
}

extension ModifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            avatarImageView.image = image
        }
    }
}
