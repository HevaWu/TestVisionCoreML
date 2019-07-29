//
//  MainTabViewController.swift
//  TestVisionCoreML
//
//  Created by He Wu on 2019/07/29.
//  Copyright © 2019 He Wu. All rights reserved.
//

import Foundation
import UIKit

class MainTabViewController: UITabBarController {
    let tabBarItems: [UITabBarItem] = [
        UITabBarItem(title: "Choose Photo", image: #imageLiteral(resourceName: "first.pdf"), tag: 0),
        UITabBarItem(title: "Take Photo", image: #imageLiteral(resourceName: "second.pdf"), tag: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let choosePhotoVC = ChoosePhotoViewController()
        let takePhotoVC = TakePhotoViewController()
        
        
        choosePhotoVC.tabBarItem = UITabBarItem(title: "Choose Photo", image: #imageLiteral(resourceName: "first.pdf"), tag: 0)
        takePhotoVC.tabBarItem = UITabBarItem(title: "Take Photo", image: #imageLiteral(resourceName: "second.pdf"), tag: 1)
        
        setViewControllers([choosePhotoVC, takePhotoVC], animated: false)
        
        self.selectedIndex = 0
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.tag {
//        case 0:
//            // choose photo
//
//        case 1:
//            // take photo
//        }
//    }
}
