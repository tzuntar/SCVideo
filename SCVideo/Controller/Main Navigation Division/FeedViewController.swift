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
    var currentSession: UserSession?
    var lastNode: PostNode?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationItem.title = "Objave"
        self.tableNode = ASTableNode(style: .plain)
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(tableNode.view, at: 0)
        self.applyStyles()
        self.tableNode.leadingScreensForBatching = 1.0  // overriding the default of 2.0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode.frame = self.view.bounds
    }
    
    private func applyStyles() {
        self.view.backgroundColor = .systemPink
        self.tableNode.view.separatorStyle = .singleLine
        self.tableNode.view.isPagingEnabled = true
    }
}

// MARK: - Video Feed Data Source
extension FeedViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]
        return {
            let node = PostNode(with: post)
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
        return true
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
        /*
         let query = PFQuery(className: "Post")
         query.order(byAscending: "createdAt")
         query.includeKey("asset")
         query.whereKey("status", equalTo: "ready")
         query.limit = 2
         query.skip = posts.count
         query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
         if let error = error {
         print(error.localizedDescription)
         } else if let objects = objects {
         print("Successfully retrieved \(objects.count) posts.")
         DispatchQueue.main.async {
         block(objects)
         }
         }
         }
         */
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
