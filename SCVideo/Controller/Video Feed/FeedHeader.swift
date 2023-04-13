//
//  FeedHeader.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/11/23.
//

import UIKit

class FeedHeader: UIView {

    @IBOutlet var contentView: UIView!

    private let _CONTENT_XIB_NAME = "FeedHeader"

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        Bundle.main.loadNibNamed(_CONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

    @IBAction func showFriendsPressed(_ sender: UIButton) {
        guard let swipeVC = superview as? MainSwipeNavigationViewController else { return }
        swipeVC.moveToPage(0, animated: true)
    }

    @IBAction func showRecordPressed(_ sender: UIButton) {
        guard let swipeVC = superview as? MainSwipeNavigationViewController else { return }
        swipeVC.moveToPage(2, animated: true)
    }

}
