//
//  UIButton+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import UIKit

extension UIButton {
    
    func setUnderline(_ width: Double) {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSAttributedString(
            string: title,
            attributes:[
                NSAttributedString.Key.underlineStyle: width
            ]
        )
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
}
