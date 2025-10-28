//
//  MainTabBarController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/18.
//  底部Tabbar标签栏

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = HomeViewController()
        let knowledge = KnowledgeViewController()
       let emergency = EmergencyViewController()
       // let emergency = modelViewController()
        let mine = MineViewController()
        
        let homeImage = UIImage(named: "home")?.resize(to: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
        home.tabBarItem = UITabBarItem(
            title: "首页",
            image: homeImage,
            selectedImage: homeImage
        )
        
        let emergencyImage = UIImage(named: "emergency")?.resize(to: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
        emergency.tabBarItem = UITabBarItem(
            title: "应急",
            image: emergencyImage,
            selectedImage: emergencyImage
        )
        
        let knowledgeImage = UIImage(named: "knowledge")?.resize(to: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
        knowledge.tabBarItem = UITabBarItem(
            title: "知识",
            image: knowledgeImage,
            selectedImage: knowledgeImage
        )
        
        let mineImage = UIImage(named: "mine")?.resize(to: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
        mine.tabBarItem = UITabBarItem(
            title: "我的",
            image: mineImage,
            selectedImage: mineImage
        )
        
        let homeNav = UINavigationController(rootViewController: home)
        let emergencyNav = UINavigationController(rootViewController: emergency)
        let knowledgeNav = UINavigationController(rootViewController: knowledge)
        let mineNav = UINavigationController(rootViewController: mine)
        viewControllers = [homeNav,emergencyNav,knowledgeNav,mineNav]
        
        UITabBar.appearance().tintColor = UIColor.tabbar_redcolor
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
