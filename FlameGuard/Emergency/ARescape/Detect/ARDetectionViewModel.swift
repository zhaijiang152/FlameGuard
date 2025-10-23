import Foundation
import Combine
import ARKit
import RealityKit

class ARDetectionViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var detectionStatus: String = "正在扫描环境..."
    @Published var isObstacleDetected: Bool = false
    @Published var showWarning: Bool = false
    @Published var confidenceLevel: Double = 0.0
    
    var arSession: ARSession?
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 1.0
    
    // 障碍物检测参数
    private let obstacleDistanceThreshold: Float = 2.5
    private let criticalDistanceThreshold: Float = 1.2
    private let minFeaturePointsForDetection: Int = 30
    
    // 稳定性检测参数
    private var detectionHistory: [Bool] = []
    private let historySize: Int = 3
    private let consistentDetectionsRequired: Int = 2 // 添加这个变量
    
    func setupARSession() {
        // 如果已有会话，先暂停
        arSession?.pause()
        
        // 创建新会话
        arSession = ARSession()
        arSession?.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // 立即运行会话
        arSession?.run(configuration)
        
        // 重置状态
        DispatchQueue.main.async {
            self.detectionStatus = "正在扫描环境..."
            self.isObstacleDetected = false
            self.showWarning = false
            self.confidenceLevel = 0.0
            self.detectionHistory.removeAll()
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastUpdateTime < updateInterval {
            return
        }
        lastUpdateTime = currentTime
        
        DispatchQueue.main.async {
            self.analyzeFrame(frame)
        }
    }
    
    private func analyzeFrame(_ frame: ARFrame) {
        // 1. 首先检查是否有足够的特征点
        guard let rawFeaturePoints = frame.rawFeaturePoints,
              rawFeaturePoints.points.count >= minFeaturePointsForDetection else {
            updateStatus("请缓慢移动设备扫描环境", isObstacle: false, confidence: 0)
            return
        }
        
        // 2. 多层级障碍物检测
        let detectionResults = performMultiLevelObstacleDetection(frame: frame)
        
        // 3. 稳定性检查
        detectionHistory.append(detectionResults.isObstacle)
        if detectionHistory.count > historySize {
            detectionHistory.removeFirst()
        }
        
        // 需要连续多次检测到障碍物才确认
        let obstacleCount = detectionHistory.filter { $0 }.count
        let isStableObstacle = obstacleCount >= consistentDetectionsRequired
        
        // 4. 更新状态
        if detectionResults.isCritical {
            updateStatus("⚠️ 前方有障碍物！危险距离", isObstacle: true, confidence: 1.0)
        } else if isStableObstacle {
            updateStatus("前方有障碍物", isObstacle: true, confidence: detectionResults.confidence)
        } else if detectionResults.isObstacle {
            updateStatus("检测到可能的障碍物", isObstacle: true, confidence: detectionResults.confidence * 0.7)
        } else {
            updateStatus("✅ 路径畅通，可安全通行", isObstacle: false, confidence: 0.9)
        }
    }
    
    private func performMultiLevelObstacleDetection(frame: ARFrame) -> (isObstacle: Bool, isCritical: Bool, confidence: Double) {
        var totalConfidence: Double = 0
        var detectionCount: Int = 0
        var isCritical: Bool = false
        
        // 检测1: 深度数据检测（最可靠）
        if let depthResult = detectObstaclesFromDepthData(frame: frame) {
            totalConfidence += depthResult.confidence
            detectionCount += 1
            if depthResult.isCritical {
                isCritical = true
            }
        }
        
        // 检测2: 特征点密度检测
        if let featureResult = detectObstaclesFromFeaturePoints(frame: frame) {
            totalConfidence += featureResult.confidence
            detectionCount += 1
            if featureResult.isCritical {
                isCritical = true
            }
        }
        
        // 检测3: 平面检测
        if let planeResult = detectObstaclesFromPlanes(frame: frame) {
            totalConfidence += planeResult.confidence
            detectionCount += 1
        }
        
        // 计算平均置信度
        let averageConfidence = detectionCount > 0 ? totalConfidence / Double(detectionCount) : 0
        
        // 如果有任一检测认为有障碍物，就返回有障碍物
        let hasObstacle = averageConfidence > 0.4
        
        return (hasObstacle, isCritical, averageConfidence)
    }
    
    private func detectObstaclesFromDepthData(frame: ARFrame) -> (isCritical: Bool, confidence: Double)? {
        guard let depthData = frame.capturedDepthData else {
            return nil
        }
        
        let depthMap = depthData.depthDataMap
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return nil
        }
        
        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        var criticalPointCount = 0
        var obstaclePointCount = 0
        var totalValidPoints = 0
        
        // 检测中心区域（视野中央）
        let centerX = width / 2
        let centerY = height / 2
        let detectionRadius = min(width, height) / 4
        
        for y in max(0, centerY - detectionRadius)..<min(height, centerY + detectionRadius) {
            for x in max(0, centerX - detectionRadius)..<min(width, centerX + detectionRadius) {
                let index = y * width + x
                let depth = floatBuffer[index]
                
                if depth > 0 {
                    totalValidPoints += 1
                    
                    if depth < criticalDistanceThreshold {
                        criticalPointCount += 1
                    } else if depth < obstacleDistanceThreshold {
                        obstaclePointCount += 1
                    }
                }
            }
        }
        
        guard totalValidPoints > 10 else { return nil }
        
        let criticalRatio = Double(criticalPointCount) / Double(totalValidPoints)
        let obstacleRatio = Double(obstaclePointCount) / Double(totalValidPoints)
        
        let isCritical = criticalRatio > 0.1
        let confidence = min(1.0, (criticalRatio * 2.0) + obstacleRatio)
        
        return (isCritical, confidence)
    }
    
    private func detectObstaclesFromFeaturePoints(frame: ARFrame) -> (isCritical: Bool, confidence: Double)? {
        guard let rawFeaturePoints = frame.rawFeaturePoints else {
            return nil
        }
        
        let points = rawFeaturePoints.points
        var criticalPoints = 0
        var obstaclePoints = 0
        
        for point in points {
            // 只考虑视野中央的点
            if abs(point.x) < 0.5 && abs(point.y) < 0.5 {
                if point.z > 0 && point.z < criticalDistanceThreshold {
                    criticalPoints += 1
                } else if point.z > 0 && point.z < obstacleDistanceThreshold {
                    obstaclePoints += 1
                }
            }
        }
        
        let totalRelevantPoints = criticalPoints + obstaclePoints
        guard totalRelevantPoints > 5 else { return nil }
        
        let criticalRatio = Double(criticalPoints) / Double(totalRelevantPoints)
        let obstacleRatio = Double(obstaclePoints) / Double(totalRelevantPoints)
        
        let isCritical = criticalRatio > 0.15
        let confidence = min(1.0, (criticalRatio * 1.5) + obstacleRatio)
        
        return (isCritical, confidence)
    }
    
    private func detectObstaclesFromPlanes(frame: ARFrame) -> (isCritical: Bool, confidence: Double)? {
        var verticalPlaneCount = 0
        
        for anchor in frame.anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor,
               planeAnchor.alignment == .vertical {
                
                // 检查平面是否在障碍物距离内
                let planePosition = simd_make_float3(
                    planeAnchor.transform.columns.3.x,
                    planeAnchor.transform.columns.3.y,
                    planeAnchor.transform.columns.3.z
                )
                
                let cameraPosition = simd_make_float3(
                    frame.camera.transform.columns.3.x,
                    frame.camera.transform.columns.3.y,
                    frame.camera.transform.columns.3.z
                )
                
                let distance = simd_distance(planePosition, cameraPosition)
                
                if distance < obstacleDistanceThreshold {
                    verticalPlaneCount += 1
                }
            }
        }
        
        guard verticalPlaneCount > 0 else { return nil }
        
        // 每个检测到的垂直平面增加置信度
        let confidence = min(1.0, Double(verticalPlaneCount) * 0.3)
        return (false, confidence)
    }
    
    private func updateStatus(_ status: String, isObstacle: Bool, confidence: Double) {
        DispatchQueue.main.async {
            self.detectionStatus = status
            self.isObstacleDetected = isObstacle
            self.showWarning = isObstacle && confidence > 0.6
            self.confidenceLevel = confidence
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.detectionStatus = "AR会话失败: \(error.localizedDescription)"
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.detectionStatus = "AR会话中断"
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.detectionStatus = "恢复扫描..."
        }
        session.run(ARWorldTrackingConfiguration())
    }
}
