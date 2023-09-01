//
//  UILabel.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/14.
//

import UIKit

extension UIButton {
    func setImage(_ mjtImage: MJTImage, tintColor: UIColor? = nil) {
        DispatchQueue.main.async {
            if let tintColor = tintColor {
                let image = mjtImage.image?.withTintColor(tintColor)
                self.setImage(image, for: .normal)
            } else {
                self.setImage(mjtImage.image, for: .normal)
            }
        }
    }
}
