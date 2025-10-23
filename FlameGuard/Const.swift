//
//  Const.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/18.
//

import UIKit

//Home
extension UIColor{
    static let quick_redcolor = UIColor(red: 171/255, green: 31/255, blue: 30/255, alpha: 0.1)
    static let quick_yellowcolor = UIColor(red: 200/255, green: 162/255, blue: 100/255, alpha: 0.1)
    static let quick_bluecolor = UIColor(red: 48/255, green: 111/255, blue: 208/255, alpha: 0.1)
    static let quick_greencolor = UIColor(red: 18/255, green: 175/255, blue: 84/255, alpha: 0.1)
    
    static let tabbar_redcolor = UIColor(red: 171/255, green: 31/255, blue: 30/255, alpha: 1)
    static let segment_redcolor = UIColor(red: 171/255, green: 31/255, blue: 30/255, alpha: 0.3)
    
    static let learn_pinklinearcolor = UIColor(red: 252/255, green: 232/255, blue:232/255, alpha: 1)
    static let learn_yellowlinearcolor = UIColor(red: 253/255, green: 245/255, blue: 232/255, alpha: 1)
    static let learn_bluelinearcolor = UIColor(red: 232/255, green: 240/255, blue: 252/255, alpha: 1)
    static let learn_greenlinearcolor = UIColor(red: 232/255, green: 252/255, blue: 237/255, alpha: 1)
    
    static let learn_pinkcolor = UIColor(red: 171/255, green: 31/255, blue:30/255, alpha: 1)
    static let learn_yellowcolor = UIColor(red: 200/255, green: 162/255, blue:100/255, alpha: 1)
    static let learn_bluecolor = UIColor(red: 48/255, green: 111/255, blue: 208/255, alpha: 1)
    static let learn_greencolor = UIColor(red: 18/255, green: 175/255, blue: 84/255, alpha: 1)
    
    static let chat_bluecolor = UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1)
}

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

extension UIColor {
    /// 检查 UIColor 的 RGBA 是否在合法范围
    func checkValidComponents() {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // 获取 RGBA 值
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            print("⚠️ 无法获取 UIColor 组件，可能是系统颜色或模式颜色")
            return
        }
        
        // 检查范围
        if !(0...1).contains(red) {
            print("⚠️ UIColor 红色组件超出范围: \(red)")
        }
        if !(0...1).contains(green) {
            print("⚠️ UIColor 绿色组件超出范围: \(green)")
        }
        if !(0...1).contains(blue) {
            print("⚠️ UIColor 蓝色组件超出范围: \(blue)")
        }
        if !(0...1).contains(alpha) {
            print("⚠️ UIColor alpha 组件超出范围: \(alpha)")
        }
    }
}
