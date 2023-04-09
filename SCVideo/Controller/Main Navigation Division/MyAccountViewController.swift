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
    @IBOutlet weak var bioPlaceholderLabel: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    
    private var currentUser: User?
    private var userPosts: [Post]?

    private var avatarPicker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = AuthManager.shared.session!.user
        hideKeyboardWhenTappedAround()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.register(UINib(nibName: "EditablePostCell", bundle: nil),
                                forCellReuseIdentifier: "EditablePostCell")

        profilePic.layer.cornerRadius = profilePic.layer.frame.height / 2
        bioTextBox.layer.borderWidth = 2
        bioTextBox.layer.borderColor = UIColor(named: "DescriptionTextLabel")?.cgColor
        bioTextBox.layer.cornerRadius = 8
        bioTextBox.delegate = self
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(profilePicPressed)))

        nameLabel.text = currentUser!.full_name
        usernameLabel.text = "@\(currentUser!.username)"
        if let bio = currentUser!.bio {
            bioTextBox.text = bio
            bioPlaceholderLabel.isHidden = true
        }
        if let avatarURL = currentUser!.photo_uri {
            profilePic.loadFrom(URLAddress: "\(APIURL)/images/profile/\(avatarURL)")
        }
        DispatchQueue.global(qos: .background).async {
            self.fetchUserPosts()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // do this in the background to avoid blocking the UI in case of failures
        guard bioTextBox.text != currentUser!.bio else { return }
        DispatchQueue.global(qos: .background).async {
            UserLogic.updateBio(self.bioTextBox.text) { result in
                switch result {
                case .success(let user):
                    self.reloadUserChanges(user)
                case .failure(let error):
                    print("Updating bio failed: \(error)")
                }
            }
        }
    }

    @objc func profilePicPressed() {
        showAvatarPicker()
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
            DispatchQueue.main.async { [weak self] in
                self?.postsTableView.reloadData()
            }
        }
    }

    private func reloadUserChanges(_ updatedUser: User) {
        guard let currentSession = AuthManager.shared.session else { return }
        AuthManager.shared.session = UserSession(token: currentSession.token,
                                                  user: updatedUser)
        currentUser = updatedUser
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

// MARK - Bio Text View Delegate

extension MyAccountViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        bioPlaceholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            bioPlaceholderLabel.isHidden = false
        }
    }
}

// MARK: - Avatar Photo Picker Delegate

extension MyAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func showAvatarPicker() {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) { return }
        avatarPicker = UIImagePickerController()
        guard let picker = avatarPicker else { return }
        picker.delegate = self
        picker.sourceType = .photoLibrary
        if let types = UIImagePickerController.availableMediaTypes(for: picker.sourceType) {
            if !types.contains("public.image") { return }
        }
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let avatar = info[.originalImage] as? UIImage else { return }
        UserLogic.uploadNewAvatar(avatar) { result in
            switch result {
            case .success(let updatedUser):
                self.reloadUserChanges(updatedUser)
                self.profilePic.image = avatar
            case .failure(let error):
                print("Failed to change the user's avatar: \(error)")
            }
        }
    }
}
