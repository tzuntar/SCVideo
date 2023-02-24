//
//  WarningAlertViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 11/2/22.
//

import UIKit

class WarningAlert: UIViewController {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.layer.borderWidth = 2
        rootView.layer.borderColor = UIColor.black.cgColor
        rootView.layer.cornerRadius = 12
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    init() {
        super.init(nibName: "WarningAlert", bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWarning(withTitle title: String,
                     withDescription desc: String,
                     withButton button: String = "Zapri") {
        show()
        headerLabel.text = title
        descriptionLabel.text = desc
        closeButton.setTitle(button, for: .normal)
    }
    
    private func show() {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
    }
}
