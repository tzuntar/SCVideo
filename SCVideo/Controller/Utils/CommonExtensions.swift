//
// Created by Tobija Žuntar on 10/28/22.
//

import UIKit

extension UIImageView {
    func loadFrom(URLAddress address: String) {
        guard let url = URL(string: address) else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = loadedImage
                    }
                }
            }
        }
    }
}

extension UITableViewCell {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
