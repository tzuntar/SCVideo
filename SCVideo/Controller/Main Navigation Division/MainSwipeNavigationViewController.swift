//
//  MainSwipeNavigationController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/6/23.
//

import UIKit

class MainSwipeNavigationViewController: EZSwipeController {
    
    var currentSession: UserSession?
    
    override func setupView() {
        super.setupView()
        navigationBarShouldNotExist = true
        datasource = self
    }
}

extension MainSwipeNavigationViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let friendsVC: FriendsViewController = storyboard.instantiateViewController(identifier: "friends-vc")
        let feedVC: FeedViewController = storyboard.instantiateViewController(identifier: "feed-vc")
        let recordVC: RecordViewController = storyboard.instantiateViewController(identifier: "record-vc")
        
        friendsVC.currentSession = currentSession
        feedVC.currentSession = currentSession
        
        return [friendsVC, feedVC, recordVC]
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
}
