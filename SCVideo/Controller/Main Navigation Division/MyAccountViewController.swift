//
//  MyAccountViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import UIKit

class MyAccountViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var bioTextBox: UITextView!
    @IBOutlet weak var postsTableView: UITableView!
    
    private var currentUser: User?
    private var userPosts: [Post]?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = AuthManager.shared.session!.user
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.register(UINib(nibName: "EditablePostCell", bundle: nil),
                                forCellReuseIdentifier: "EditablePostCell")

        profilePic.layer.cornerRadius = profilePic.layer.frame.height / 2
        bioTextBox.layer.borderWidth = 3
        bioTextBox.layer.borderColor = UIColor(named: "DescriptionTextLabel")?.cgColor
        bioTextBox.layer.cornerRadius = 8

        nameLabel.text = currentUser!.full_name
        usernameLabel.text = "@\(currentUser!.username)"
        bioTextBox.text = currentUser!.bio
        if let avatarURL = currentUser!.photo_uri {
            profilePic.loadFrom(URLAddress: "\(APIURL)/images/profile/\(avatarURL)")
        }
        fetchUserPosts()
    }

    @IBAction func selectProfilePicPressed(_ sender: UIButton) {
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        AuthManager.shared.endSession()
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginController = loginStoryboard.instantiateViewController(withIdentifier: "login-vc")
        loginController.modalPresentationStyle = .fullScreen
        present(loginController, animated: true, completion: nil)
    }

    private func fetchUserPosts() {
        PostLoaderLogic.loadPostsForUser(currentUser!) { (posts: [Post]?) in
            self.userPosts = posts
            self.postsTableView.reloadData()
        }
    }
}

extension MyAccountViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = userPosts else { return 0 }
        return posts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditablePostCell", for: indexPath) as! EditablePostCell
        guard let posts = userPosts else { return cell }
        cell.configure(for: posts[indexPath.item])
        return cell
    }

}

extension MyAccountViewController: UITableViewDelegate {

    private func handleDelete(_ post: Post) {
        PostActionsLogic.delete(post) { deleted in
            if !deleted { return }
            self.userPosts?.removeAll(where: { $0.id_post == post.id_post })
            self.postsTableView.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Odstrani objavo") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            let post = self.userPosts![indexPath.item]
            self.handleDelete(post)
            completion(true)
        }
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
