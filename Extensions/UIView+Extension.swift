//
//  UIView+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
