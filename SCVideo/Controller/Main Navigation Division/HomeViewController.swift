//
//  HomeViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/25/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    var posts: [Post]?
    var currentSession: UserSession?
    var feed: FeedLogic?
    var selectedPost: Post?
    var selectedPostUser: User?
    
    @IBOutlet weak var postsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.dataSource = self
        postsTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        if let tabBarController = self.tabBarController {
            guard let parentController = tabBarController as? MainTabBarController else { return }
            guard let session = parentController.session else { return }
            currentSession = session
//            feed = FeedLogic(session: session, withDelegate: self)
            DispatchQueue.main.async {
                self.feed!.retrieveFeedPosts()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPostComments" {
            guard let commentsVC = segue.destination as? CommentsViewController else { return }
            guard let post = selectedPost else { return }
            commentsVC.currentSession = currentSession
            commentsVC.currentPost = post
        } else if segue.identifier == "showPostAccount" {
            guard let profileVC = segue.destination as? UserProfileViewController else { return }
            guard let user = selectedPostUser else { return }
            profileVC.currentSession = currentSession
            profileVC.currentUser = user
        }
    }
}

// MARK: - Feed Handling Division

extension HomeViewController: FeedDelegate {
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
        postsTableView.reloadData()
    }
    
    func didFetchingFailWithError(_ error: Error) {
        print(error)
    }
}

// MARK: - Table View Data Handling

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = self.posts else { return 0 }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        guard let posts = self.posts,
              let session = self.currentSession else { return cell }
        cell.loadData(forPost: posts[indexPath.row], asSession: session)
        return cell
    }
    
}
