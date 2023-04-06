//
//  CommentsViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/29/22.
//

import UIKit

class CommentsViewController: UIViewController {

    var currentPost: Post?
    var comments: [Comment]?
    var commentsLogic: CommentsLogic?
    var selectedCommenter: User?

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var writeCommentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        commentsTableView.dataSource = self
        commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil),
                                   forCellReuseIdentifier: "CommentCell")

        if let post = currentPost {
            commentsLogic = CommentsLogic(delegatingActionsTo: self)
            commentsLogic!.retrieveComments(forPost: post)
        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendCommentPressed(_ sender: UIButton) {
        if let body = writeCommentField.text,
           let post = currentPost {
            writeCommentField.endEditing(true)
            commentsLogic!.postComment(with: CommentEntry(
                                    id_post: post.id_post,
                                    id_user: AuthManager.shared.session!.user.id_user,
                                    content: body))
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommenterAccount" {
            guard let commenterProfileVC = segue.destination as? UserProfileViewController,
                  let commenter = selectedCommenter else { return }
            commenterProfileVC.currentUser = commenter
        }
    }
}

// MARK: - Comment Handling Division

extension CommentsViewController: CommentsDelegate {
    func didFetchComments(_ comments: [Comment]) {
        self.comments = comments
        commentsTableView.reloadData()
    }
    
    func didPostCommentSuccessfully() {
        commentsLogic!.retrieveComments(forPost: currentPost!)
        writeCommentField.text = ""
    }

    func didFetchingFailWithError(_ error: Error) {
        print(error)
    }
}

// MARK: - Table View Data Handling

extension CommentsViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = comments else { return 0 }
        return comments.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell",
                                                 for: indexPath) as! CommentCell
        guard let comments = comments else { return cell }
        cell.loadComment(comments[indexPath.row])
        return cell
    }
}
