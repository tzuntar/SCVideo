//
//  Separator.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/17/22.
//

import UIKit

class SeparatorCell: UITableViewCell {

    let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorView.backgroundColor = UIColor(named: "DescriptionTextLabel")
        separatorView.alpha = 0.5
        contentView.addSubview(separatorView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }

}