//
//  ContentView.swift
//  DormEscapeApp
//
//  Created by 黑麦 on 2025/9/6.
//
import SwiftUI
import ARKit

struct DetectContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isARSupported: Bool = {
        return ARWorldTrackingConfiguration.isSupported
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 应用标题
                    Text("火灾求生助手")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    if !isARSupported {
                        VStack {
                            Text("设备不支持AR功能")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                            Text("请使用iPhone 6s或更新设备")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        // 原有的内容...
                        Image(systemName: "flame.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .shadow(color: .orange, radius: 10)
                        
                        Spacer()
                        
                        // 障碍检测按钮
                        NavigationLink(destination: ARDetectionView()) {
                            HStack {
                                Image(systemName: "viewfinder")
                                Text("障碍检测")
                                    .fontWeight(.semibold)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.orange)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal, 50)
                    }
                    
                    // 其他UI元素...
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                        Text("返回")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}
