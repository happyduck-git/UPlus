//
//  UIImageView.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/14.
//

import UIKit

extension UIImageView {
    func setImage(_ mjtImage: MJTImage) {
        DispatchQueue.main.async {
            self.image = mjtImage.image
        }
    }
}
