//
//  MainTabBarController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var session: UserSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        if let items = self.tabBar.items {
            items[0].selectedImage = UIImage(named: "FriendsSelected")?.withRenderingMode(.alwaysOriginal)
            items[1].selectedImage = UIImage(named: "HomeSelected")?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: "CameraSelected")?.withRenderingMode(.alwaysOriginal)
            items[3].selectedImage = UIImage(named: "UploadSelected")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
}
