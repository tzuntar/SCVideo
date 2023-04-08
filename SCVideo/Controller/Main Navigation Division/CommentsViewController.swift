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
    @IBOutlet weak var stackViewBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil),
                                   forCellReuseIdentifier: "CommentCell")

        if let post = currentPost {
            commentsLogic = CommentsLogic(delegatingActionsTo: self)
            commentsLogic!.retrieveComments(forPost: post)
        }

        // Notification Center for keyboard handling
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil);
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil);
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
                                    id_comment: nil,
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

    @objc func keyboardWillShow(_ notification: Notification) {
        if writeCommentField.isEditing {    // this check prevents unwanted view movement
            moveViewWithKeyboard(notification, viewBottomConstraint: stackViewBottom, keyboardWillShow: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        moveViewWithKeyboard(notification, viewBottomConstraint: stackViewBottom, keyboardWillShow: false)
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

    func didDeleteCommentSuccessfully(_ commentEntry: CommentEntry) {
        comments?.removeAll(where: { $0.id_comment == commentEntry.id_comment })
        commentsTableView.reloadData()
    }

    func didFetchingFailWithError(_ error: Error) {
        print(error)
    }
}

// MARK: - Comments Table View Handling

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

extension CommentsViewController: UITableViewDelegate {

    private func handleDelete(_ comment: Comment) {
        commentsLogic?.deleteComment(with: CommentEntry(id_post: currentPost!.id_post,
                                                        id_user: nil,
                                                        id_comment: comment.id_comment,
                                                        content: nil))
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if comments![indexPath.item].user.id_user != AuthManager.shared.session!.user.id_user {
            return nil  // only let the user delete their own comments
        }
        let delete = UIContextualAction(style: .destructive, title: "Izbriši komentar") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            let comment = self.comments![indexPath.item]
            self.handleDelete(comment)
            completion(true)
        }
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }

}