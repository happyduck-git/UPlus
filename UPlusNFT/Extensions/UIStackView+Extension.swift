//
//  UIStackView+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
}
