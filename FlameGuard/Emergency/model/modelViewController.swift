//
//  ViewController.swift
//  G7
//
//  Created by 清云 on 2025/6/23.
//

import UIKit
import SnapKit
import PhotosUI
import AVKit
import CoreML
import Vision

class modelViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "火焰监测")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .systemGray6
        iv.isUserInteractionEnabled = false
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.systemGray3.cgColor
        iv.layer.cornerRadius = 12
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.1
        iv.layer.shadowRadius = 5
        iv.layer.shadowOffset = CGSize(width: 0, height: 2)
        return iv
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择照片或视频进行检测"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var detectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("检测火焰", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(onDetectTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择媒体", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(onSelectMediaTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("停止检测", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(onStopDetectionTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Properties
    private let detector = FireDetectionManager()
    private var videoURL: URL?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var displayLink: CADisplayLink?
    private var isDetectingVideo = false
    private var lastDetectionTime: CMTime = .zero
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        setupUI()
        setupGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = imageView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVideoDetection()
        player?.pause()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white

        let buttonStackView = UIStackView(arrangedSubviews: [
            selectMediaButton,
            detectButton,
            stopDetectionButton
        ])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
       
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false  // ← 添加这一行！
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
          imageView.translatesAutoresizingMaskIntoConstraints = false
          resultLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerImageView)
        view.addSubview(imageView)
        view.addSubview(resultLabel)
        view.addSubview(buttonStackView)

        headerImageView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(80)
        }

        imageView.snp.remakeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(400)
        }

        resultLabel.snp.remakeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        buttonStackView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(resultLabel.snp.bottom).offset(20)
            make.height.equalTo(55)
        }

        selectMediaButton.isUserInteractionEnabled = true
           detectButton.isUserInteractionEnabled = true
           stopDetectionButton.isUserInteractionEnabled = true
           
        
        [selectMediaButton, detectButton, stopDetectionButton].forEach {
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        }
        
        
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onImageTapped))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func onSelectMediaTapped() {
        presentMediaPicker()
    }
    
    @objc private func onDetectTapped() {
        if player != nil {
            // 如果是视频，开始实时检测
            startVideoDetection()
            resultLabel.text = "正在实时检测视频中的火焰..."
        } else if imageView.image != nil {
            // 如果是图片，单次检测
            detectImage()
        } else {
            resultLabel.text = "请先选择图片或视频"
        }
    }
    
    @objc private func onStopDetectionTapped() {
        stopVideoDetection()
        resultLabel.text = "已停止检测"
    }
    
    @objc private func onImageTapped() {
        if player != nil {
            // 如果是视频，点击暂停/播放
            if player?.rate == 0 {
                player?.play()
            } else {
                player?.pause()
            }
        } else {
            // 如果是图片，打开选择器
            presentMediaPicker()
        }
    }
    
    // MARK: - Media Picker
    
    private func presentMediaPicker() {
        // 1️⃣ 检查相册访问权限
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            // 已授权 -> 直接打开选择器
            openPicker()
        case .notDetermined:
            // 首次访问 -> 弹出系统权限弹窗
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.openPicker()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        default:
            // 用户拒绝或受限制
            showPermissionAlert()
        }
    }

    // 分离出选择器逻辑
    private func openPicker() {
        if #available(iOS 14.0, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .any(of: [.videos, .images])
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie", "public.image"]
            picker.delegate = self
            present(picker, animated: true)
        }
    }

    // 当权限被拒绝时提示用户去设置中开启
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "无法访问相册",
            message: "请前往设置 > 隐私 > 照片，允许本应用访问相册。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }
    
    
    
    
    
    
    
//    private func presentMediaPicker() {
//        if #available(iOS 14.0, *) {
//            var config = PHPickerConfiguration()
//            config.selectionLimit = 1
//            config.filter = .any(of: [.videos, .images])
//            
//            let picker = PHPickerViewController(configuration: config)
//            picker.delegate = self
//            present(picker, animated: true)
//        } else {
//            let picker = UIImagePickerController()
//            picker.sourceType = .photoLibrary
//            picker.mediaTypes = ["public.movie", "public.image"]
//            picker.delegate = self
//            present(picker, animated: true)
//        }
//    }
    
    // MARK: - Video Handling
    private func setupVideoPlayer(with url: URL) {
        // 清除旧状态
        stopVideoDetection()
        playerLayer?.removeFromSuperlayer()
        player = nil
        
        // 创建新播放器
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = imageView.bounds
        playerLayer?.videoGravity = .resizeAspect
        imageView.layer.addSublayer(playerLayer!)
        
        // 隐藏静态图片
        imageView.image = nil
        
        // 开始播放
        player?.play()
        
        // 设置循环播放
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                             object: player?.currentItem,
                                             queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
        
        // 更新UI状态
        stopDetectionButton.isHidden = false
        resultLabel.text = "已选择视频，点击检测按钮开始分析"
    }
    
    private func startVideoDetection() {
        guard player != nil else { return }
        
        stopVideoDetection()
        isDetectingVideo = true
        
        // 使用CADisplayLink实现与屏幕刷新率同步的检测
        displayLink = CADisplayLink(target: self, selector: #selector(processVideoFrame))
        displayLink?.add(to: .main, forMode: .common)
        
        stopDetectionButton.isHidden = false
    }
    
    private func stopVideoDetection() {
        displayLink?.invalidate()
        displayLink = nil
        isDetectingVideo = false
        stopDetectionButton.isHidden = true
    }
    
    @objc private func processVideoFrame() {
        guard isDetectingVideo, let player = player else { return }
        
        let currentTime = player.currentTime()
        
        // 控制检测频率（每0.3秒检测一次）
        if currentTime.seconds - lastDetectionTime.seconds < 0.3 {
            return
        }
        lastDetectionTime = currentTime
        
        // 获取当前视频帧
        guard let asset = player.currentItem?.asset else { return }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: currentTime, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
            // 执行检测
            detector.detectFire(in: uiImage) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let detections):
                        self?.handleDetections(detections)
                    case .failure(let error):
                        self?.resultLabel.text = "检测错误: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            print("获取视频帧失败: \(error)")
        }
    }
    
    // MARK: - Image Handling
    private func detectImage() {
        guard let image = imageView.image else { return }
        
        resultLabel.text = "检测中..."
        detectButton.isEnabled = false
        
        detector.detectFire(in: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.detectButton.isEnabled = true
                
                switch result {
                case .success(let detections):
                    self?.handleDetections(detections)
                case .failure(let error):
                    self?.resultLabel.text = "错误: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Detection Handling
    private func handleDetections(_ detections: [FireDetection]) {
        // 清除旧标记
        imageView.layer.sublayers?.filter { $0.name == "detection" }.forEach { $0.removeFromSuperlayer() }
        
        if detections.isEmpty {
            resultLabel.text = player != nil ? "实时检测中 - 未发现火焰" : "未检测到火焰"
            return
        }
        
        // 显示结果
        let confidenceText = detections.map { String(format: "%.1f%%", $0.confidence * 100) }.joined(separator: ", ")
        resultLabel.text = player != nil
            ? "实时检测中 - 发现 \(detections.count) 处火焰"
            : "检测到 \(detections.count) 处火焰\n置信度: \(confidenceText)"
        
        // 绘制检测框
        for detection in detections {
            let layer = CALayer()
            layer.name = "detection"
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 2
            layer.frame = convertToImageRect(normalizedRect: detection.boundingBox)
            imageView.layer.addSublayer(layer)
        }
    }
    
    private func convertToImageRect(normalizedRect: CGRect) -> CGRect {
        let imageSize = imageView.image?.size ?? imageView.bounds.size
        let imageViewSize = imageView.bounds.size
        let scale = min(imageViewSize.width / imageSize.width, imageViewSize.height / imageSize.height)
        let offsetX = (imageViewSize.width - imageSize.width * scale) / 2
        let offsetY = (imageViewSize.height - imageSize.height * scale) / 2
        
        return CGRect(
            x: normalizedRect.origin.x * imageSize.width * scale + offsetX,
            y: (1 - normalizedRect.origin.y - normalizedRect.height) * imageSize.height * scale + offsetY,
            width: normalizedRect.width * imageSize.width * scale,
            height: normalizedRect.height * imageSize.height * scale
        )
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, *)
extension modelViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            // 处理图片选择
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.stopVideoDetection()
                        self?.playerLayer?.removeFromSuperlayer()
                        self?.player = nil
                        self?.imageView.image = image
                        self?.resultLabel.text = "已选择图片，点击检测按钮进行分析"
                        self?.stopDetectionButton.isHidden = true
                    }
                }
            }
        } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            // 处理视频选择
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                guard let url = url else { return }
                
                // 复制视频到临时目录
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                
                try? FileManager.default.copyItem(at: url, to: tempURL)
                
                DispatchQueue.main.async {
                    self?.setupVideoPlayer(with: tempURL)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension modelViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            // 处理图片选择
            stopVideoDetection()
            playerLayer?.removeFromSuperlayer()
            player = nil
            imageView.image = image
            resultLabel.text = "已选择图片，点击检测按钮进行分析"
            stopDetectionButton.isHidden = true
        } else if let videoURL = info[.mediaURL] as? URL {
            // 处理视频选择
            setupVideoPlayer(with: videoURL)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - FireDetection Model
struct FireDetection {
    let boundingBox: CGRect  // 归一化坐标 (0-1)
    let confidence: Float
}

class FireDetectionManager {
    private var model: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config = MLModelConfiguration()
                let coreMLModel = try yolov8_fire(configuration: config)
                self.model = try VNCoreMLModel(for: coreMLModel.model)
            } catch {
                print("模型加载失败: \(error)")
            }
        }
    }
    
    func detectFire(in image: UIImage, completion: @escaping (Result<[FireDetection], Error>) -> Void) {
        guard let model = model else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "模型未初始化"])))
            return
        }
        
        // 创建 VNCoreMLRequest 时直接设置 completionHandler
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion(.success([]))
                return
            }
            
            let detections = results.map { observation -> FireDetection in
                FireDetection(
                    boundingBox: observation.boundingBox,
                    confidence: Float(observation.confidence)
                )
            }
            
            completion(.success(detections))
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let cgImage = image.cgImage else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "无法获取图像数据"])))
                return
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}
