import SwiftUI
import ARKit
import RealityKit
import CoreMotion
import Combine

// MARK: - 数据模型
struct SavedMap: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var pathPoints: [PathPoint]
    var dateCreated: Date
    
    init(id: UUID = UUID(), name: String, pathPoints: [PathPoint], dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.pathPoints = pathPoints
        self.dateCreated = dateCreated
    }
    
    // 如果需要自定义编码/解码，可以添加以下方法：
    enum CodingKeys: String, CodingKey {
        case id, name, pathPoints, dateCreated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pathPoints = try container.decode([PathPoint].self, forKey: .pathPoints)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(pathPoints, forKey: .pathPoints)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}

struct PathPoint: Equatable, Codable {
    var x: Float
    var y: Float
    var z: Float
    var direction: Double // 方向（弧度）
    var distanceFromStart: Float // 距离起点的距离
    
    // 如果需要自定义编码/解码，可以添加以下方法：
    enum CodingKeys: String, CodingKey {
        case x, y, z, direction, distanceFromStart
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(Float.self, forKey: .x)
        y = try container.decode(Float.self, forKey: .y)
        z = try container.decode(Float.self, forKey: .z)
        direction = try container.decode(Double.self, forKey: .direction)
        distanceFromStart = try container.decode(Float.self, forKey: .distanceFromStart)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
        try container.encode(direction, forKey: .direction)
        try container.encode(distanceFromStart, forKey: .distanceFromStart)
    }
    
    // 为了方便，添加一个简单的初始化方法
    init(x: Float, y: Float, z: Float, direction: Double, distanceFromStart: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.direction = direction
        self.distanceFromStart = distanceFromStart
    }
}

// MARK: - 数据管理
class MapDataManager: ObservableObject {
    
    @Published var savedMaps: [SavedMap] = []
    
    init() {
        defer { loadMaps() }
    }
    
    func saveMap(_ map: SavedMap) {
        if let index = savedMaps.firstIndex(where: { $0.id == map.id }) {
            savedMaps[index] = map
        } else {
            savedMaps.append(map)
        }
        saveMaps()
    }
    
    func deleteMap(_ map: SavedMap) {
        savedMaps.removeAll { $0.id == map.id }
        saveMaps()
    }
    
    private func saveMaps() {
        do {
            let data = try JSONEncoder().encode(savedMaps)
            UserDefaults.standard.set(data, forKey: "savedMaps")
        } catch {
            print("保存地图失败: \(error)")
        }
    }
    
    private func loadMaps() {
        guard let data = UserDefaults.standard.data(forKey: "savedMaps") else { return }
        do {
            savedMaps = try JSONDecoder().decode([SavedMap].self, from: data)
        } catch {
            print("加载地图失败: \(error)")
        }
    }
}

// MARK: - AR视图和导航器
struct ARViewContainer: UIViewRepresentable {
    var mode: ARMode
    var pathPoints: [PathPoint]
    @Binding var currentPoint: PathPoint?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置AR会话
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading // 使用重力方向和设备朝向
        arView.session.run(config)
        
        if mode == .navigation, let currentPoint = currentPoint {
            // 在导航模式下显示路径
            showPath(in: arView, pathPoints: pathPoints, currentPoint: currentPoint)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if mode == .navigation, let currentPoint = currentPoint {
            // 更新导航路径
            uiView.scene.anchors.removeAll()
            showPath(in: uiView, pathPoints: pathPoints, currentPoint: currentPoint)
        }
    }
    
    private func showPath(in arView: ARView, pathPoints: [PathPoint], currentPoint: PathPoint) {
        // 创建路径锚点
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        
        // 添加起点标记
        let startSphere = MeshResource.generateSphere(radius: 0.1)
        let startMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let startEntity = ModelEntity(mesh: startSphere, materials: [startMaterial])
        startEntity.position = SIMD3<Float>(0, 0, 0)
        anchor.addChild(startEntity)
        
        // 添加终点标记
        if let lastPoint = pathPoints.last {
            let endSphere = MeshResource.generateSphere(radius: 0.15)
            let endMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let endEntity = ModelEntity(mesh: endSphere, materials: [endMaterial])
            endEntity.position = SIMD3<Float>(lastPoint.x, lastPoint.y, lastPoint.z)
            anchor.addChild(endEntity)
        }
        
        // 添加路径线
        for i in 0..<pathPoints.count-1 {
            let current = pathPoints[i]
            let next = pathPoints[i+1]
            
            let line = createLineBetween(
                start: SIMD3<Float>(current.x, current.y, current.z),
                end: SIMD3<Float>(next.x, next.y, next.z)
            )
            anchor.addChild(line)
        }
        
        // 添加当前位置标记
        let currentSphere = MeshResource.generateSphere(radius: 0.08)
        let currentMaterial = SimpleMaterial(color: .blue, isMetallic: false)
        let currentEntity = ModelEntity(mesh: currentSphere, materials: [currentMaterial])
        currentEntity.position = SIMD3<Float>(currentPoint.x, currentPoint.y, currentPoint.z)
        anchor.addChild(currentEntity)
        
        // 添加方向指示器
        let direction = createDirectionIndicator(direction: currentPoint.direction)
        direction.position = SIMD3<Float>(currentPoint.x, currentPoint.y + 0.2, currentPoint.z)
        anchor.addChild(direction)
        
        arView.scene.addAnchor(anchor)
    }
    
    private func createLineBetween(start: SIMD3<Float>, end: SIMD3<Float>) -> ModelEntity {
        let distance = length(end - start)
        let line = MeshResource.generateBox(size: [0.02, 0.02, distance])
        let material = SimpleMaterial(color: .yellow, isMetallic: false)
        let entity = ModelEntity(mesh: line, materials: [material])
        
        let midPoint = (start + end) / 2
        entity.position = midPoint
        
        let direction = normalize(end - start)
        entity.look(at: end, from: midPoint, relativeTo: nil)
        
        return entity
    }
    
    private func createDirectionIndicator(direction: Double) -> ModelEntity {
        let arrow = MeshResource.generateBox(size: [0.05, 0.05, 0.2])
        let material = SimpleMaterial(color: .cyan, isMetallic: false)
        let entity = ModelEntity(mesh: arrow, materials: [material])
        
        // 根据方向旋转箭头
        let rotation = simd_quatf(angle: Float(direction), axis: [0, 1, 0])
        entity.orientation = rotation
        
        return entity
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        uiView.session.pause()
    }
}

enum ARMode {
    case recording
    case navigation
}

// MARK: - 路径记录器
class PathRecorder: NSObject, ObservableObject {
    private let motionManager = CMMotionManager()
        private var lastPosition: SIMD3<Float>?
        private var currentPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
        
        // 将 heading 改为 @Published 以便视图可以访问
        @Published var heading: Double = 0
        @Published var pathPoints: [PathPoint] = []
        @Published var isRecording = false
        @Published var totalDistance: Float = 0
        
        override init() {
            super.init()
            setupMotionManager()
        }
        
        private func setupMotionManager() {
            // 设置设备运动更新
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1
                motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
                    guard let self = self, let motion = motion, self.isRecording else { return }
                    
                    // 获取设备朝向
                    self.heading = -motion.attitude.yaw // 调整方向
                    
                    // 计算位移（简化处理，实际应用中需要更复杂的算法）
                    let acceleration = motion.userAcceleration
                    let deltaTime = 0.1
                    
                    // 简化的位移计算（实际应用中需要更精确的算法）
                    let displacement = SIMD3<Float>(
                        Float(acceleration.x * deltaTime * deltaTime * 5),
                        Float(acceleration.y * deltaTime * deltaTime * 5),
                        Float(acceleration.z * deltaTime * deltaTime * 5)
                    )
                    
                    // 根据方向旋转位移向量
                    let rotatedDisplacement = self.rotateVector(displacement, by: self.heading)
                    self.currentPosition += rotatedDisplacement
                    
                    // 更新总距离
                    if let lastPos = self.lastPosition {
                        let distance = length(self.currentPosition - lastPos)
                        self.totalDistance += distance
                    }
                    
                    // 记录路径点
                    let pathPoint = PathPoint(
                        x: self.currentPosition.x,
                        y: self.currentPosition.y,
                        z: self.currentPosition.z,
                        direction: self.heading,
                        distanceFromStart: self.totalDistance
                    )
                    
                    self.pathPoints.append(pathPoint)
                    self.lastPosition = self.currentPosition
                }
            }
        }
    
    private func rotateVector(_ vector: SIMD3<Float>, by angle: Double) -> SIMD3<Float> {
        let cosAngle = Float(cos(angle))
        let sinAngle = Float(sin(angle))
        
        return SIMD3<Float>(
            vector.x * cosAngle - vector.z * sinAngle,
            vector.y,
            vector.x * sinAngle + vector.z * cosAngle
        )
    }
    
    func startRecording() {
        reset()
        isRecording = true
    }
    
    func stopRecording() {
        isRecording = false
    }
    
    func reset() {
        pathPoints.removeAll()
        lastPosition = nil
        currentPosition = SIMD3<Float>(0, 0, 0)
        totalDistance = 0
    }
}

// MARK: - 导航器
class PathNavigator: NSObject, ObservableObject {
    private let motionManager = CMMotionManager()
    
    // 将 currentPosition 改为可选类型
    @Published var currentPosition: PathPoint? = nil
    @Published var isNavigating = false
    @Published var progress: Float = 0
    @Published var distanceToDestination: Float = 0
    
    var pathPoints: [PathPoint] = []
    private var currentPathIndex: Int = 0
    
    override init() {
        super.init()
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion, self.isNavigating else { return }
                
                // 更新当前位置和方向
                let heading = -motion.attitude.yaw
                
                // 简化的导航逻辑 - 沿着路径移动
                if self.currentPathIndex < self.pathPoints.count - 1 {
                    let nextIndex = self.currentPathIndex + 1
                    let nextPoint = self.pathPoints[nextIndex]
                    
                    // 检查是否到达下一个点
                    let distanceToNext = length(SIMD3<Float>(
                        self.currentPosition?.x ?? 0 - nextPoint.x,
                        self.currentPosition?.y ?? 0 - nextPoint.y,
                        self.currentPosition?.z ?? 0 - nextPoint.z
                    ))
                    
                    if distanceToNext < 0.3 { // 阈值，表示已到达下一个点
                        self.currentPathIndex = nextIndex
                    }
                }
                
                // 更新当前位置（简化模拟）
                if self.currentPathIndex < self.pathPoints.count {
                    let targetPoint = self.pathPoints[self.currentPathIndex]
                    self.currentPosition = PathPoint(
                        x: targetPoint.x,
                        y: targetPoint.y,
                        z: targetPoint.z,
                        direction: heading,
                        distanceFromStart: targetPoint.distanceFromStart
                    )
                }
                
                // 更新进度和距离
                if let lastPoint = self.pathPoints.last, let currentPosition = self.currentPosition {
                    self.distanceToDestination = lastPoint.distanceFromStart - currentPosition.distanceFromStart
                    self.progress = currentPosition.distanceFromStart / lastPoint.distanceFromStart
                }
                
                // 检查是否到达终点
                if self.currentPathIndex == self.pathPoints.count - 1 && self.distanceToDestination < 0.5 {
                    self.isNavigating = false
                }
            }
        }
    }
    
    func startNavigation(with path: [PathPoint]) {
        self.pathPoints = path
        self.currentPathIndex = 0
        self.isNavigating = true
        self.progress = 0
        self.currentPosition = PathPoint(
            x: path.first?.x ?? 0,
            y: path.first?.y ?? 0,
            z: path.first?.z ?? 0,
            direction: 0,
            distanceFromStart: 0
        )
        self.distanceToDestination = path.last?.distanceFromStart ?? 0
    }
    
    func stopNavigation() {
        isNavigating = false
        currentPosition = nil
    }
}

// MARK: - 主视图
struct ContentView: View {
    @StateObject private var mapDataManager = MapDataManager()
    @State private var showingARView = false
    @State private var showingNavigation = false
    @State private var selectedMap: SavedMap?
    @State private var showingDeleteAlert = false
    @State private var mapToDelete: SavedMap?
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ZStack {
                // 渐变色背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemBackground).opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                if mapDataManager.savedMaps.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        Section(header:
                            HStack {
                                Text("已保存的地图")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(mapDataManager.savedMaps.count)个")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.orange.opacity(0.1)))
                            }
                            .padding(.vertical, 8)
                        ) {
                            ForEach(mapDataManager.savedMaps) { map in
                                MapCardView(map: map)
                                    .onTapGesture {
                                        selectedMap = map
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            mapToDelete = map
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            // 分享功能占位
                                        } label: {
                                            Label("分享", systemImage: "square.and.arrow.up")
                                        }
                                        .tint(.blue)
                                    }
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            .padding(.vertical, 4)
                                    )
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("火灾逃生导航")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.black)
                                    Text("返回")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingARView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingARView) {
                ARRecordingView(mapDataManager: mapDataManager)
            }
            .sheet(item: $selectedMap) { map in
                MapDetailView(map: map, mapDataManager: mapDataManager)
            }
            .alert("删除地图", isPresented: $showingDeleteAlert, presenting: mapToDelete) { map in
                Button("删除", role: .destructive) {
                    mapDataManager.deleteMap(map)
                }
                Button("取消", role: .cancel) {}
            } message: { map in
                Text("确定要删除「\(map.name)」吗？此操作无法撤销。")
            }
        }
        .accentColor(.orange)
    }
}
// 空状态视图
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("暂无保存的地图")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text("点击右下角按钮开始记录您的第一条逃生路线")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - AR录制视图
struct ARRecordingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var mapDataManager: MapDataManager
    @StateObject private var pathRecorder = PathRecorder()
    @State private var mapName: String = ""
    @State private var showingSaveAlert = false
    @State private var showingDiscardAlert = false
    
    var body: some View {
        ZStack {
            ARViewContainer(mode: .recording, pathPoints: [], currentPoint: .constant(nil))
                .edgesIgnoringSafeArea(.all)
            
            // 半透明覆盖层
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.3), .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 顶部控制栏
                HStack {
                    Button {
                        if pathRecorder.pathPoints.isEmpty {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showingDiscardAlert = true
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.black.opacity(0.4)))
                    }
                    
                    Spacer()
                    
                    if pathRecorder.isRecording {
                        RecordingIndicator()
                    }
                    
                    Spacer()
                    
                    if pathRecorder.isRecording {
                        Button {
                            pathRecorder.stopRecording()
                            showingSaveAlert = true
                        } label: {
                            Text("完成")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.red))
                        }
                    } else {
                        Button {
                            pathRecorder.startRecording()
                        } label: {
                            Text("开始记录")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.green))
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // 数据面板
                VStack(spacing: 16) {
                    RecordingStatsView(
                        pointCount: pathRecorder.pathPoints.count,
                        totalDistance: pathRecorder.totalDistance,
                        isRecording: pathRecorder.isRecording
                    )
                    
                    CompassView(heading: pathRecorder.heading)
                        .frame(width: 80, height: 80)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .padding()
            }
        }
        .alert("保存路径", isPresented: $showingSaveAlert) {
            TextField("路线名称", text: $mapName)
            Button("保存") {
                let newMap = SavedMap(
                    name: mapName.isEmpty ? "未命名路线 \(Date().formatted(date: .abbreviated, time: .shortened))" : mapName,
                    pathPoints: pathRecorder.pathPoints
                )
                mapDataManager.saveMap(newMap)
                presentationMode.wrappedValue.dismiss()
            }
            Button("取消", role: .cancel) {
                mapName = ""
            }
        } message: {
            Text("请输入这条逃生路线的名称")
        }
        .alert("放弃记录？", isPresented: $showingDiscardAlert) {
            Button("放弃", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("继续记录", role: .cancel) {}
        } message: {
            Text("当前记录的路径将会丢失")
        }
    }
}

// 录制指示器
struct RecordingIndicator: View {
    @State private var isBlinking = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .opacity(isBlinking ? 1 : 0.3)
                .animation(.easeInOut(duration: 1).repeatForever(), value: isBlinking)
            
            Text("录制中")
                .font(.caption)
                .foregroundColor(.white)
        }
        .onAppear { isBlinking = true }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(.black.opacity(0.4)))
    }
}

// 录制统计视图
struct RecordingStatsView: View {
    let pointCount: Int
    let totalDistance: Float
    let isRecording: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                value: "\(pointCount)",
                label: "路径点",
                icon: "point.fill",
                color: .blue
            )
            
            Divider()
                .frame(height: 30)
                .background(Color.white.opacity(0.3))
            
            StatItem(
                value: String(format: "%.1fm", totalDistance),
                label: "距离",
                icon: "ruler",
                color: .green
            )
            
            Divider()
                .frame(height: 30)
                .background(Color.white.opacity(0.3))
            
            StatItem(
                value: isRecording ? "进行中" : "已暂停",
                label: "状态",
                icon: isRecording ? "record.circle" : "pause.circle",
                color: isRecording ? .red : .orange
            )
        }
    }
}

// 统计项组件
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Label(value, systemImage: icon)
                .font(.system(.body, design: .monospaced).weight(.medium))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - 地图详情视图优化

// 详情卡片视图
struct DetailCardView: View {
    let map: SavedMap
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("路线详情")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                DetailItem(
                    value: "\(map.pathPoints.count)",
                    label: "路径点",
                    icon: "point.fill"
                )
                
                DetailItem(
                    value: String(format: "%.1fm", (map.pathPoints.last?.distanceFromStart ?? 0) * 10),
                    label: "总距离",
                    icon: "ruler"
                )
                
                DetailItem(
                    value: map.dateCreated.formatted(date: .abbreviated, time: .omitted),
                    label: "创建日期",
                    icon: "calendar"
                )
            }
            
            Text("逃生指引：请沿着记录的路径快速有序地撤离，注意观察周围环境变化。")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

// 详情项组件
struct DetailItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            Text(value)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 操作栏组件
struct ActionBar: View {
    let onStartNavigation: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                onShare()
            } label: {
                Label("分享", systemImage: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            
            Button {
                onStartNavigation()
            } label: {
                Label("开始导航", systemImage: "location.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}
// MARK: - AR导航视图优化

// 导航进度视图
struct NavigationProgressView: View {
    let progress: Float
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(progress * 100))%")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 6)
                
                Capsule()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: CGFloat(progress) * 100, height: 6)
            }
        }
        .padding(8)
        .background(Capsule().fill(.black.opacity(0.4)))
    }
}

// 导航面板
struct NavigationPanel: View {
    let distanceToDestination: Float
    let progress: Float
    
    var body: some View {
        VStack(spacing: 16) {
            Text("正在导航到安全地点")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                NavigationInfoItem(
                    value: String(format: "%.1fm", distanceToDestination),
                    label: "剩余距离",
                    icon: "arrow.right"
                )
                
                NavigationInfoItem(
                    value: "\(Int(progress * 100))%",
                    label: "完成进度",
                    icon: "percent"
                )
            }
            
            Text("请按照箭头指示方向前进，注意脚下安全")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// 导航信息项
struct NavigationInfoItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// 辅助工具
private let relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.locale = Locale(identifier: "zh_CN")
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "zh_CN")
    return formatter
}()

// MARK: - 地图详情视图
struct MapDetailView: View {
    let map: SavedMap
    @ObservedObject var mapDataManager: MapDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingARNavigation = false
    @StateObject private var pathNavigator = PathNavigator()
    
    var body: some View {
        ZStack {
            // 2D地图视图
            MapPathView(pathPoints: map.pathPoints)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button("返回") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("AR导航") {
                        showingARNavigation = true
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                VStack {
                    Text(map.name)
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("路径点: \(map.pathPoints.count)")
                        .foregroundColor(.white)
                    Text("总距离: \(String(format: "%.2f", (map.pathPoints.last?.distanceFromStart ?? 0) * 10)) 米")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingARNavigation) {
            ARNavigationView(pathPoints: map.pathPoints, pathNavigator: pathNavigator)
        }
    }
}

// MARK: - AR导航视图
struct ARNavigationView: View {
    let pathPoints: [PathPoint]
    @ObservedObject var pathNavigator: PathNavigator
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var fireManager = FireEntityManager()
    @State private var showingCompletionAlert = false
    
    var body: some View {
        ZStack {
            // AR视图
            ARNavigationContainer(
                pathPoints: pathPoints,
                currentPoint: $pathNavigator.currentPosition,
                fireManager: fireManager
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button("退出导航") {
                        pathNavigator.stopNavigation()
                        fireManager.removeFire()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.body.weight(.medium))
                    
                    Spacer()
                    
                    // 只在火焰放置后显示导航按钮
                    if fireManager.isFirePlaced && !pathNavigator.isNavigating {
                        Button("开始导航") {
                            pathNavigator.startNavigation(with: pathPoints)
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.body.weight(.medium))
                    }
                }
                .padding()
                
                Spacer()
                
                // 导航信息面板
                if pathNavigator.isNavigating {
                    VStack(spacing: 12) {
                        Text("导航中...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("进度: \(String(format: "%.1f", pathNavigator.progress * 100))%")
                            .foregroundColor(.white)
                            .font(.body.weight(.medium))
                        
                        Text("距离终点: \(String(format: "%.2f", pathNavigator.distanceToDestination)) 米")
                            .foregroundColor(.white)
                            .font(.body)
                        
                        // 进度条
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: CGFloat(pathNavigator.progress) * 200, height: 8)
                                .cornerRadius(4)
                        }
                        .frame(width: 200)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.bottom, 30)
                } else if !fireManager.isFirePlaced {
                    // 火焰放置提示
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        VStack(spacing: 8) {
                            Text("正在识别场景...")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("请缓慢移动设备以识别周围平面")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            // 延迟一下开始放置火焰，让AR场景先加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                fireManager.placeFireOnPlane()
            }
        }
        .onChange(of: pathNavigator.isNavigating) { isNavigating in
            if !isNavigating && pathNavigator.distanceToDestination < 0.5 {
                showingCompletionAlert = true
            }
        }
        .alert("导航完成", isPresented: $showingCompletionAlert) {
            Button("确定") {
                fireManager.removeFire()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("您已成功到达安全地点！")
        }
    }
}

// MARK: - 2D地图路径视图
struct MapPathView: View {
    let pathPoints: [PathPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let scale = calculateScale(geometry: geometry)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 背景网格
                GridView()
                
                // 路径线
                Path { path in
                    if let firstPoint = pathPoints.first {
                        let startX = center.x + CGFloat(firstPoint.x) * scale
                        let startY = center.y + CGFloat(firstPoint.z) * scale
                        path.move(to: CGPoint(x: startX, y: startY))
                        
                        for point in pathPoints.dropFirst() {
                            let x = center.x + CGFloat(point.x) * scale
                            let y = center.y + CGFloat(point.z) * scale
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 3)
                
                // 路径点
                ForEach(0..<pathPoints.count, id: \.self) { index in
                    let point = pathPoints[index]
                    let x = center.x + CGFloat(point.x) * scale
                    let y = center.y + CGFloat(point.z) * scale
                    
                    Circle()
                        .fill(index == 0 ? Color.green : (index == pathPoints.count - 1 ? Color.red : Color.blue))
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
                
                // 方向指示
                if let lastPoint = pathPoints.last {
                    let endX = center.x + CGFloat(lastPoint.x) * scale
                    let endY = center.y + CGFloat(lastPoint.z) * scale
                    
                    Path { path in
                        path.move(to: CGPoint(x: endX, y: endY))
                        let arrowX = endX + CGFloat(cos(lastPoint.direction)) * 20
                        let arrowY = endY + CGFloat(sin(lastPoint.direction)) * 20
                        path.addLine(to: CGPoint(x: arrowX, y: arrowY))
                    }
                    .stroke(Color.red, lineWidth: 2)
                }
            }
        }
    }
    
    private func calculateScale(geometry: GeometryProxy) -> CGFloat {
        guard !pathPoints.isEmpty else { return 1.0 }
        
        let maxX = pathPoints.map { abs($0.x) }.max() ?? 1
        let maxZ = pathPoints.map { abs($0.z) }.max() ?? 1
        let maxDimension = max(maxX, maxZ)
        
        let availableSize = min(geometry.size.width, geometry.size.height) / 2
        return availableSize / CGFloat(maxDimension + 1)
    }
}

// MARK: - 网格视图
struct GridView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing: CGFloat = 20
            
            // 垂直线
            ForEach(0..<Int(width / spacing), id: \.self) { index in
                Path { path in
                    let x = CGFloat(index) * spacing
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
            
            // 水平线
            ForEach(0..<Int(height / spacing), id: \.self) { index in
                Path { path in
                    let y = CGFloat(index) * spacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
            
            // 中心十字线
            Path { path in
                // 垂直线
                path.move(to: CGPoint(x: width / 2, y: 0))
                path.addLine(to: CGPoint(x: width / 2, y: height))
                // 水平线
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width, y: height / 2))
            }
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            
            // 方向标签
            Text("北")
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: width / 2, y: 10)
            Text("南")
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: width / 2, y: height - 10)
            Text("西")
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: 10, y: height / 2)
            Text("东")
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: width - 10, y: height / 2)
        }
    }
}

// MARK: - 指南针视图
struct CompassView: View {
    let heading: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.5))
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            // 方向指示器
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: 40)
                .offset(y: -20)
                .rotationEffect(Angle(radians: heading))
            
            // 方向标签
            Text("N")
                .font(.caption)
                .foregroundColor(.white)
                .offset(y: -30)
            Text("S")
                .font(.caption)
                .foregroundColor(.white)
                .offset(y: 30)
            Text("E")
                .font(.caption)
                .foregroundColor(.white)
                .offset(x: 30)
            Text("W")
                .font(.caption)
                .foregroundColor(.white)
                .offset(x: -30)
        }
    }
}

// 地图卡片视图
struct MapCardView: View {
    let map: SavedMap
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(map.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("创建于 \(map.dateCreated, formatter: relativeDateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 16) {
                Label("\(map.pathPoints.count)个路径点", systemImage: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(String(format: "%.1f", (map.pathPoints.last?.distanceFromStart ?? 0) * 10))米", systemImage: "ruler")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 迷你路径预览
//            MiniPathPreview(pathPoints: map.pathPoints)
//                .frame(height: 40)
//                .cornerRadius(8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}


import SwiftUI
import ARKit
import RealityKit
import CoreMotion

// MARK: - 简化版火焰实体管理器
class FireEntityManager: ObservableObject {
    private var fireEntity: Entity?
    private var arView: ARView?
    private var animationTimer: Timer?
    
    @Published var isFirePlaced = false
    
    func setup(arView: ARView) {
        self.arView = arView
        setupARConfiguration()
    }
    
    private func setupARConfiguration() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
    }
    
    func placeFireOnPlane() {
        // 尝试加载OBJ火焰模型
        if let customFire = loadCustomFireModel() {
            placeEntityOnDetectedPlane(customFire)
        }
        // 如果加载失败，创建程序化火焰作为备用
        else {
            createCustomFireEntity()
        }
    }
    
    // 加载自定义火焰模型 - OBJ版本
    private func loadCustomFireModel() -> Entity? {
        do {
            print("开始加载OBJ火焰模型...")
            
            // 加载OBJ模型文件
            let fireEntity = try Entity.loadModel(named: "火焰.obj")
            print("OBJ模型加载成功")
            
            // 尝试加载火焰纹理
            if let fireTexture = try? TextureResource.load(named: "火焰1") {
                print("火焰纹理加载成功")
                
                var material = SimpleMaterial()
                material.color = .init(texture: .init(fireTexture))
                material.roughness = .init(floatLiteral: 0.1)
                material.metallic = .init(floatLiteral: 0.0)
                
                // 应用材质到所有子实体
                applyMaterialToEntity(fireEntity, material: material)
                print("材质应用完成")
            } else {
                print("火焰纹理加载失败，使用默认材质")
                // 如果纹理加载失败，使用橙色默认材质
                applyDefaultMaterialToEntity(fireEntity)
            }
            
            // 调整火焰大小 - 增大3倍
            fireEntity.scale = SIMD3<Float>(1.5, 1.5, 1.5) // 从0.5改为1.5，增大3倍
            print("模型缩放设置完成 - 增大3倍")
            
            return fireEntity
            
        } catch {
            print("加载OBJ火焰模型失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 递归应用材质到实体及其所有子实体
    private func applyMaterialToEntity(_ entity: Entity, material: SimpleMaterial) {
        if let modelEntity = entity as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        
        // 递归应用到所有子实体
        for child in entity.children {
            applyMaterialToEntity(child, material: material)
        }
    }
    
    // 应用默认材质
    private func applyDefaultMaterialToEntity(_ entity: Entity) {
        var material = SimpleMaterial()
        material.color = .init(tint: .orange)
        material.roughness = .init(floatLiteral: 0.2)
        material.metallic = .init(floatLiteral: 0.0)
        
        applyMaterialToEntity(entity, material: material)
    }
    
    // 备用方案：程序化火焰
    private func createCustomFireEntity() {
        print("使用程序化火焰作为备用方案")
        
        let fireEntity = Entity()
        
        // 创建火焰 - 增大3-4倍
        let flames = [
            (height: 0.9, radius: 0.24, color: UIColor.yellow, yOffset: 0.45),    // 增大3倍
            (height: 0.75, radius: 0.18, color: UIColor.orange, yOffset: 0.9),   // 增大3倍
            (height: 0.6, radius: 0.12, color: UIColor.red, yOffset: 1.35)       // 增大3倍
        ]
        
        for flame in flames {
            let flameMesh = MeshResource.generateCone(height: Float(flame.height), radius: Float(flame.radius))
            var material = SimpleMaterial()
            material.color = .init(tint: flame.color)
            material.roughness = .init(floatLiteral: 0.1)
            material.metallic = .init(floatLiteral: 0.0)
            
            let flameEntity = ModelEntity(mesh: flameMesh, materials: [material])
            flameEntity.position.y = Float(flame.yOffset)
            fireEntity.addChild(flameEntity)
        }
        
        placeEntityOnDetectedPlane(fireEntity)
    }
    
    // 在检测到的平面上放置实体
    private func placeEntityOnDetectedPlane(_ entity: Entity) {
        guard let arView = arView else { return }
        
        print("正在寻找平面放置火焰...")
        
        // 使用平面检测锚点，这会自动将实体放置在检测到的平面上
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.5, 0.5])
        
        // 获取相机位置和方向
        let cameraTransform = arView.cameraTransform
        let cameraPosition = cameraTransform.translation
        let cameraForward = getCameraForwardVector(from: cameraTransform.matrix)
        
        // 在相机前方2米处放置火焰（稍微远一点因为火焰变大了）
        let distance: Float = 2.0
        let targetPosition = cameraPosition + cameraForward * distance
        
        // 设置锚点位置 - 平面锚点会自动将Y轴设置为平面高度
        anchor.position = SIMD3<Float>(targetPosition.x, 0, targetPosition.z)
        
        // 关键：将火焰实体的位置重置，确保它从平面开始生长
        entity.position = SIMD3<Float>(0, 0, 0)
        
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        self.fireEntity = entity
        
        print("火焰已紧贴平面放置，大小增大3倍")
        
        // 添加火焰动画
        addFireAnimation(to: entity)
        
        // 标记火焰已放置
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isFirePlaced = true
            print("火焰放置完成，可以开始导航")
        }
    }
    
    // 获取相机前向向量
    private func getCameraForwardVector(from matrix: float4x4) -> SIMD3<Float> {
        return SIMD3<Float>(-matrix.columns.2.x, -matrix.columns.2.y, -matrix.columns.2.z)
    }
    
    private func addFireAnimation(to entity: Entity) {
        let originalScale = entity.scale
        
        // 创建新的动画计时器 - 只做缩放动画
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            guard let self = self, self.fireEntity != nil else {
                timer.invalidate()
                return
            }
            
            // 缩放动画
            let randomScale = Float.random(in: 0.9...1.1)
            let newScale = originalScale * SIMD3<Float>(randomScale, randomScale * 1.2, randomScale)
            
            var transform = entity.transform
            transform.scale = newScale
            
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
        }
    }
    
    func removeFire() {
        print("移除火焰实体")
        
        // 停止动画
        animationTimer?.invalidate()
        animationTimer = nil
        
        guard let arView = arView, let fireEntity = fireEntity else { return }
        
        // 找到并移除包含火焰的锚点
        if let anchor = fireEntity.anchor {
            arView.scene.removeAnchor(anchor)
        }
        
        self.fireEntity = nil
        self.isFirePlaced = false
    }
}

// MARK: - 新的AR导航容器
// MARK: - 简化版AR导航容器
struct ARNavigationContainer: UIViewRepresentable {
    var pathPoints: [PathPoint]
    @Binding var currentPoint: PathPoint?
    var fireManager: FireEntityManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置AR会话
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        // 设置火焰管理器
        fireManager.setup(arView: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 在导航模式下显示路径
        if let currentPoint = currentPoint {
            // 清除所有路径相关的锚点
            removePathAnchors(from: uiView)
            // 显示新路径
            showPath(in: uiView, pathPoints: pathPoints, currentPoint: currentPoint)
        }
    }
    
    private func removePathAnchors(from arView: ARView) {
        // 移除所有名称包含"path"的锚点
        let pathAnchors = arView.scene.anchors.filter { $0.name.contains("path") == true }
        for anchor in pathAnchors {
            arView.scene.removeAnchor(anchor)
        }
    }
    
    private func showPath(in arView: ARView, pathPoints: [PathPoint], currentPoint: PathPoint) {
        // 创建路径锚点
        let pathAnchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        pathAnchor.name = "path_anchor"
        
        // 添加起点标记
        let startSphere = MeshResource.generateSphere(radius: 0.1)
        let startMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let startEntity = ModelEntity(mesh: startSphere, materials: [startMaterial])
        startEntity.position = SIMD3<Float>(0, 0, 0)
        pathAnchor.addChild(startEntity)
        
        // 添加终点标记
        if let lastPoint = pathPoints.last {
            let endSphere = MeshResource.generateSphere(radius: 0.15)
            let endMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let endEntity = ModelEntity(mesh: endSphere, materials: [endMaterial])
            endEntity.position = SIMD3<Float>(lastPoint.x, lastPoint.y, lastPoint.z)
            pathAnchor.addChild(endEntity)
        }
        
        // 添加路径线
        for i in 0..<pathPoints.count-1 {
            let current = pathPoints[i]
            let next = pathPoints[i+1]
            
            let line = createLineBetween(
                start: SIMD3<Float>(current.x, current.y, current.z),
                end: SIMD3<Float>(next.x, next.y, next.z)
            )
            pathAnchor.addChild(line)
        }
        
        // 添加当前位置标记
        let currentSphere = MeshResource.generateSphere(radius: 0.08)
        let currentMaterial = SimpleMaterial(color: .blue, isMetallic: false)
        let currentEntity = ModelEntity(mesh: currentSphere, materials: [currentMaterial])
        currentEntity.position = SIMD3<Float>(currentPoint.x, currentPoint.y, currentPoint.z)
        pathAnchor.addChild(currentEntity)
        
        // 添加方向指示器
        let direction = createDirectionIndicator(direction: currentPoint.direction)
        direction.position = SIMD3<Float>(currentPoint.x, currentPoint.y + 0.2, currentPoint.z)
        pathAnchor.addChild(direction)
        
        arView.scene.addAnchor(pathAnchor)
    }
    
    private func createLineBetween(start: SIMD3<Float>, end: SIMD3<Float>) -> ModelEntity {
        let distance = length(end - start)
        let line = MeshResource.generateBox(size: [0.02, 0.02, distance])
        let material = SimpleMaterial(color: .yellow, isMetallic: false)
        let entity = ModelEntity(mesh: line, materials: [material])
        
        let midPoint = (start + end) / 2
        entity.position = midPoint
        
        let direction = normalize(end - start)
        entity.look(at: end, from: midPoint, relativeTo: nil)
        
        return entity
    }
    
    private func createDirectionIndicator(direction: Double) -> ModelEntity {
        let arrow = MeshResource.generateBox(size: [0.05, 0.05, 0.2])
        let material = SimpleMaterial(color: .cyan, isMetallic: false)
        let entity = ModelEntity(mesh: arrow, materials: [material])
        
        // 根据方向旋转箭头
        let rotation = simd_quatf(angle: Float(direction), axis: [0, 1, 0])
        entity.orientation = rotation
        
        return entity
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        uiView.session.pause()
    }
}

// MARK: - 新的AR导航视图

// MARK: - 修改MapDetailView中的导航调用

// MARK: - 其他原有代码保持不变...
// [这里包含您之前的所有其他代码：SavedMap, PathPoint, MapDataManager, ARViewContainer, PathRecorder, PathNavigator, ContentView等]
// 请确保保留所有原有的结构体、类和方法

// 注意：您需要确保项目中有以下文件：
// 1. "火焰.obj" (或 .usdz 文件) - 3D模型文件
// 2. "火焰1.png" - 纹理图片
// 如果这些文件不存在，系统会自动创建程序化火焰
