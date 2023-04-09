//
//  FeedViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit
import AsyncDisplayKit

class FeedViewController: UIViewController, UIScrollViewDelegate {
    
    var tableNode: ASTableNode!
    var posts: [Post] = []
    var feedLogic = FeedLogic()
    var lastNode: PostNode?
    
    private var selectedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode = ASTableNode(style: .plain)
        tableNode.delegate = self
        tableNode.dataSource = self

        view.insertSubview(tableNode.view, at: 0)
        applyStyles()
        tableNode.leadingScreensForBatching = 1.0  // overriding the default of 2.0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableNode.frame = view.bounds
    }
    
    private func applyStyles() {
        view.backgroundColor = .systemPink
        tableNode.view.separatorStyle = .singleLine
        tableNode.view.isPagingEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPostComments":
            guard let destination = segue.destination as? CommentsViewController,
                  let safePost = selectedPost else { return }
            destination.currentPost = safePost
            break
        case "showPosterProfile":
            guard let destination = segue.destination as? UserProfileViewController,
                  let safePost = selectedPost else { return }
            destination.currentUser = safePost.user
            break
        default:
            return
        }
    }
}

// MARK: - Video Feed Data Source
extension FeedViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]
        return {
            let node = PostNode(with: post, delegatingActionsTo: self)
            return node
        }
    }
}

// MARK: - Video Feed Table Delegate
extension FeedViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width
        let min = CGSize(width: width, height: (UIScreen.main.bounds.size.height / 3) * 2)
        let max = CGSize(width: width, height: .infinity)
        return ASSizeRangeMake(min, max)
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        true
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        // get the next page of results
        retrieveNextPageWithCompletion { newPosts in
            self.insertNewRowsInTableNode(newPosts)
            context.completeBatchFetching(true)
        }
    }
}

// MARK: - Batched Fetching Operations
extension FeedViewController {
    func retrieveNextPageWithCompletion(block: @escaping ([Post]) -> Void) {
        feedLogic.loadPostBatch(limit: 2, offset: posts.count, completion: { (posts: [Post]?, errorCode: Int?) in
            if let error = errorCode {
                return print("Loading post batch failed with code \(error)")
            }
            guard let safePosts = posts else { return }
            DispatchQueue.main.async {
                block(safePosts)
            }
        })
    }
    
    func insertNewRowsInTableNode(_ newPosts: [Post]) {
        guard !newPosts.isEmpty else { return }
        let section = 0
        var indexPaths: [IndexPath] = []
        let total = posts.count + newPosts.count
        for row in posts.count ... total - 1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        posts.append(contentsOf: newPosts)
        tableNode.insertRows(at: indexPaths, with: .none)
    }
}

// MARK: - Post Actions Delegate
extension FeedViewController: PostNodeActionDelegate {
    func didTapLikePost(_ post: Post, isLiked: Bool) {
        selectedPost = post
    }

    func didTapCommentPost(_ post: Post) {
        selectedPost = post
        performSegue(withIdentifier: "showPostComments", sender: self)
    }

    func didTapSharePost(_ post: Post) {
        guard let videoUrl = URL(string: "\(APIURL)/posts/videos/\(post.content_uri)") else { return }
        /*URLSession.shared.downloadTask(with: videoUrl) { (location, response, error) in
            guard let location = location else {
                print("Error downloading asset: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            let shareSheet = UIActivityViewController(activityItems: [location],
                                              applicationActivities: nil)
            shareSheet.popoverPresentationController?.sourceView = self.view // fixes a crash on iPads
            shareSheet.popoverPresentationController?.sourceRect = self.view.frame
            DispatchQueue.main.async {
                self.present(shareSheet, animated: true, completion: nil)
            }
        }.resume()*/

        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(post.content_uri)
        let downloadSession = AVAssetDownloadURLSession(configuration: .default,
                                                assetDownloadDelegate: nil,
                                                        delegateQueue: .main)
        downloadSession.makeAssetDownloadTask(asset: AVURLAsset(url: videoUrl),
                                         assetTitle: post.content_uri,
                                   assetArtworkData: nil,
                                            options: nil)?.resume()
    }
    
    func didTapUserProfile(_ post: Post) {
        selectedPost = post
        performSegue(withIdentifier: "showPosterProfile", sender: self)
    }
}
