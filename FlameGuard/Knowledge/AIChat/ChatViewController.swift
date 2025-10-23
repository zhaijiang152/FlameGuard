//
//  ViewController.swift
//  AI
//
//  Created by 清云 on 2025/5/18.
//

import UIKit
import EachNavigationBar
import SnapKit

class AIController: UIViewController {
    
    private let apiKey: String
    private let glm4API: GLM4API
    
    private var messages: [GLM4Message] = []
    private var isWaitingForResponse = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        return view
    }()

    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入消息..."
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .send
        textField.delegate = self
        return textField
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var headerImageView:UIImageView = {
        let view = UIImageView(image: UIImage(named: "chatHeaderImage"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.glm4API = GLM4API(apiKey: apiKey)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
         super.viewDidLoad()
         setNaviBar()
         setupUI()
         setupKeyboardObservers()
         setupTextChangeObserver()
     }
    
    private func setNaviBar() {
        guard let originalImage = UIImage(named: "消防小助手") else { return }
        
        // 1. 使用容器视图控制布局
        let containerView = UIView()
        let imageView = UIImageView(image: originalImage.withRenderingMode(.alwaysOriginal))
        imageView.contentMode = .scaleAspectFill // 改为Fill确保填充[3](@ref)
        
        // 2. 动态计算尺寸（基于导航栏高度）
        let navBarHeight = navigation.bar.frame.height
        let targetWidth = navBarHeight * 3 // 宽度为高度的3倍
        let targetHeight = navBarHeight * 0.9 // 高度占导航栏90%
        
        // 3. 设置容器约束
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: targetWidth),
            imageView.heightAnchor.constraint(equalToConstant: targetHeight)
        ])
        
        // 4. 设置容器尺寸（关键步骤）
        containerView.frame = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        navigation.item.titleView = containerView
        
        // 5. 强制布局更新（解决首次加载不生效问题）
        DispatchQueue.main.async {
            containerView.setNeedsLayout()
            containerView.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(backgroundView)
        view.addSubview(headerImageView)
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(activityIndicator)
        
        backgroundView.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        headerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(185)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top).offset(-8)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview()
        }
            
        inputTextField.snp.makeConstraints { make in
            make.bottom.equalTo(inputContainerView.snp.bottom)
            make.leading.equalTo(inputContainerView.snp.leading).offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.top.equalTo(inputContainerView.snp.top).offset(8)
        }
        sendButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(inputContainerView.snp.trailing).offset(-16)
            make.width.equalTo(60)
        }
        activityIndicator.snp.makeConstraints { make in
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.centerY.equalTo(sendButton.snp.centerY)
        }
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 20
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        view.addSubview(backButton)
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    private var keyboardHeight: CGFloat = 0
    
    private func setupKeyboardObservers() {
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(keyboardWillShow),
               name: UIResponder.keyboardWillShowNotification,
               object: nil
           )
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(keyboardWillHide),
               name: UIResponder.keyboardWillHideNotification,
               object: nil
           )
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(keyboardWillChangeFrame),
               name: UIResponder.keyboardWillChangeFrameNotification,
               object: nil
           )
       }
       
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardHeight = keyboardFrame.height
        adjustForKeyboard(notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                // 重置输入栏位置
                self.inputContainerView.transform = .identity
                
                // 重置表格内容边距
                self.tableView.contentInset = .zero
                self.tableView.scrollIndicatorInsets = .zero
            }
        )
    }
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardHeight = keyboardFrame.height
        adjustForKeyboard(notification: notification)
    }
    
    private func setupTextChangeObserver() {
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        sendButton.isEnabled = !(inputTextField.text?.isEmpty ?? true)
    }
    

    
    private func adjustForKeyboard(notification: NSNotification) {
            guard let userInfo = notification.userInfo else { return }
            
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curve << 16),
                animations: {
                    // 调整输入栏位置
                    self.inputContainerView.transform = CGAffineTransform(
                        translationX: 0,
                        y: -self.keyboardHeight + self.view.safeAreaInsets.bottom
                    )
                    
                    // 调整表格内容边距
                    self.tableView.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: self.keyboardHeight + self.inputContainerView.frame.height,
                        right: 0
                    )
                    self.tableView.scrollIndicatorInsets = self.tableView.contentInset
                    
                    // 自动滚动到最后一条消息
                    if self.messages.count > 0 {
                        let lastIndex = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                    }
                }
            )
        }
    
    @objc private func sendMessage() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              !isWaitingForResponse else {
            return
        }
        
        // 添加用户消息
        let userMessage = GLM4Message(role: "user", content: text)
        messages.append(userMessage)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        scrollToBottom()
        
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
        sendButton.isEnabled = false
        isWaitingForResponse = true
        activityIndicator.startAnimating()
        
        // 调用API
        glm4API.sendMessage(messages: messages) { [weak self] result in
            DispatchQueue.main.async {
                self?.isWaitingForResponse = false
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    let aiMessage = GLM4Message(role: "assistant", content: response)
                    self?.messages.append(aiMessage)
                case .failure(let error):
                    let errorContent: String
                    switch error {
                    case .apiError(let message):
                        errorContent = "API错误: \(message)"
                    case .decodingFailed(let error):
                        errorContent = "解析失败: \(error.localizedDescription)"
                    case .invalidResponse:
                        errorContent = "无效的响应"
                    case .invalidURL:
                        errorContent = "无效的URL"
                    case .noContent:
                        errorContent = "无返回内容"
                    case .requestFailed(let error):
                        errorContent = "请求失败: \(error.localizedDescription)"
                    }
                    
                    let errorMessage = GLM4Message(role: "assistant", content: errorContent)
                    self?.messages.append(errorMessage)
                }
                
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded()
                self?.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            guard self.messages.count > 0 else { return }
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension AIController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension AIController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with message: GLM4Message) {
        messageLabel.text = message.content
        
        if message.role == "user" {
            bubbleView.backgroundColor = .chat_bluecolor
            messageLabel.textColor = .black
            messageLabel.textAlignment = .right
            
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.trailing.equalToSuperview().offset(-16)
                make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
            }
        } else {
            bubbleView.backgroundColor = .white
            messageLabel.textColor = .black
            messageLabel.textAlignment = .left
            
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.leading.equalToSuperview().offset(16)
                make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
            }
        }
    }
}
