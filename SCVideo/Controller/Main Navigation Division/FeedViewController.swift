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
    private var postActionsLogic: PostActionsLogic?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode = ASTableNode(style: .plain)
        tableNode.delegate = self
        tableNode.dataSource = self
        postActionsLogic = PostActionsLogic(delegatingActionsTo: self)

        view.insertSubview(tableNode.view, at: 0)
        applyStyles()
        tableNode.leadingScreensForBatching = 1.0  // overriding the default of 2.0

        let headerTop = view.safeAreaInsets.top == 0 ? 40 : view.safeAreaInsets.top + 40
        let feedHeaderView = FeedHeader()
        feedHeaderView.frame = CGRect(origin: CGPoint(x: 0, y: headerTop),
                                      size: CGSize(width: UIScreen.main.bounds.width, height: 70))
        view.addSubview(feedHeaderView)

        // the pull-to-refresh thingy
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableNode.view.refreshControl = refreshControl
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

    @objc func refreshFeed(_ sender: UIRefreshControl) {
        tableNode.reloadData()
        sender.endRefreshing()
    }
}

// MARK: - Post Node Actions Delegate
extension FeedViewController: PostNodeActionDelegate {

    func didTapLikePost(_ post: Post, isLiked: Bool) {
        selectedPost = post
        if post.is_liked == 0 {
            postActionsLogic?.like(post)
        } else {
            postActionsLogic?.unlike(post)
        }
    }

    func didTapCommentPost(_ post: Post) {
        selectedPost = post
        performSegue(withIdentifier: "showPostComments", sender: self)
    }

    func didTapSharePost(_ post: Post) {
        #if ENABLE_DOWNLOAD_CLIP_WHEN_SHARING
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

            let downloadSession = AVAssetDownloadURLSession(configuration: .background(withIdentifier: "share-sheet-download"),
                                                            assetDownloadDelegate: self,
                                                            delegateQueue: .main)
            downloadSession.makeAssetDownloadTask(asset: AVURLAsset(url: videoUrl),
                                             assetTitle: post.content_uri,
                                       assetArtworkData: nil,
                                                options: nil)?.resume()
        #else
            let videoUrl = URL(string: "\(APIURL)/posts/videos/\(post.content_uri)")!
            let activityController = UIActivityViewController(activityItems: [videoUrl],
                                                      applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        #endif
    }

    func didTapUserProfile(_ post: Post) {
        selectedPost = post
        performSegue(withIdentifier: "showPosterProfile", sender: self)
    }
}

// MARK - Post Actions Delegate Callbacks
extension FeedViewController: PostActionsDelegate {

    func didLikePost(_ post: Post) {
        print("liked")
    }

    func didUnlikePost(_ post: Post) {
        print("unliked")
    }

    func didActionFailWithError(_ error: Error) {
        print("Post action failed with error: \(error)")
    }


}

// MARK - Downloading Videos for Share Sheet
extension FeedViewController: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        let exportSession = AVAssetExportSession(asset: assetDownloadTask.urlAsset,
                                            presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = .mp4
        exportSession.outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("share.mp4");

        exportSession.exportAsynchronously {
            guard exportSession.status == .completed else {
                print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                return
            }

            DispatchQueue.main.async { [weak self] in
                let activityController = UIActivityViewController(activityItems: [exportSession.outputURL!],
                                                          applicationActivities: nil)
                self?.present(activityController, animated: true, completion: nil)
            }
        }
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection) {
        print("Download progress: \(loadedTimeRanges.count) / \(timeRangeExpectedToLoad.duration.seconds)")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let errorDesc = error?.localizedDescription ?? "unknown error"
        print("Failed to download the video to share: \(errorDesc)")
    }
}