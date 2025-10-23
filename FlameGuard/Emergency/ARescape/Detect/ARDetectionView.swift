import SwiftUI
import RealityKit
import ARKit

struct ARDetectionView: View {
    @StateObject private var viewModel = ARDetectionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var arView: ARView?
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer1(viewModel: viewModel, arView: $arView)
                .edgesIgnoringSafeArea(.all)
            
            // 半透明覆盖层
//            Color.black.opacity(0.0001) // 几乎透明的层，确保触摸事件传递
//                .edgesIgnoringSafeArea(.all)
            
            // 状态显示层
            VStack {
                Spacer()
                
                // 检测状态显示
                VStack(spacing: 20) {
                    Text(viewModel.detectionStatus)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(statusBackgroundColor)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(maxWidth: .infinity)
                    
                    if viewModel.showWarning {
                        VStack(spacing: 8) {
                            Text("🚫 紧急警告！")
                                .font(.headline)
                                .foregroundColor(.red)
                                .bold()
                            Text("前方检测到障碍物，请立即停止并寻找其他路径！")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .cornerRadius(12)
                    } else if !viewModel.isObstacleDetected {
                        VStack(spacing: 8) {
                            Text("✅ 安全通道")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("前方路径畅通，可以安全通行")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(12)
                    }
                    
                    // 检测质量指示器
                    HStack {
                        Text("检测质量:")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index < Int(viewModel.confidenceLevel * 5) ? statusColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
               .toolbar {
                   // 左侧返回按钮
//                   ToolbarItem(placement: .navigationBarLeading) {
//                       Button(action: {
//                           presentationMode.wrappedValue.dismiss()
//                       }) {
//                           Image(systemName: "chevron.left")
//                               .font(.title2)
//                               .foregroundColor(.white)
//                               .padding(8)
//                               .background(Color.blue.opacity(0.8))
//                               .clipShape(Circle())
//                       }
//                   }
                   
                   // 右侧重置按钮
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button(action: {
                           resetARSession()
                       }) {
                           Image(systemName: "arrow.clockwise")
                               .font(.title2)
                               .foregroundColor(.black)
                               .padding(8)
                               
                               .clipShape(Circle())
                       }
                   }
               }
        .onAppear {
            // 只在第一次进入时启动AR会话
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 检查是否已经有活跃的会话
                if self.arView?.session.configuration == nil {
                    // 只有没有会话时才设置
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.planeDetection = [.horizontal, .vertical]
                    self.arView?.session.run(configuration)
                    self.arView?.session.delegate = self.viewModel
                }
            }
        }
    }
    
    private var statusBackgroundColor: Color {
        if viewModel.showWarning {
            return Color.red.opacity(0.85)
        } else if viewModel.isObstacleDetected {
            return Color.orange.opacity(0.85)
        } else {
            return Color.green.opacity(0.85)
        }
    }
    
    private var statusColor: Color {
        if viewModel.showWarning {
            return .red
        } else if viewModel.isObstacleDetected {
            return .orange
        } else {
            return .green
        }
    }
    
    private func resetARSession() {
        // 先暂停当前会话
        arView?.session.pause()
        
        // 延迟一点再重新启动，避免冲突
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 创建新的配置
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.environmentTexturing = .automatic
            
            // 运行新的会话
            self.arView?.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            // 重置视图模型状态，但不要重新创建ARSession
            DispatchQueue.main.async {
                self.viewModel.detectionStatus = "正在重新扫描环境..."
                self.viewModel.isObstacleDetected = false
                self.viewModel.showWarning = false
                self.viewModel.confidenceLevel = 0.0
            }
        }
    }
}

struct ARViewContainer1: UIViewRepresentable {
    let viewModel: ARDetectionViewModel
    @Binding var arView: ARView?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.arView = arView
        
        // 设置AR配置
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // 设置AR视图选项
        arView.automaticallyConfigureSession = false // 改为false，手动配置
        arView.renderOptions = [.disableCameraGrain, .disableMotionBlur]
        
        // 检查相机权限
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    // 运行AR会话
                    arView.session.run(configuration)
                    arView.session.delegate = viewModel
                }
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 不需要在这里运行会话，避免重复配置
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        // 清理资源
        uiView.session.pause()
    }
}

struct ARDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ARDetectionView()
    }
}

