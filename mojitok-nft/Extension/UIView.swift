//
//  UIView.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/22.
//

import UIKit

extension UIView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        endEditing(true)
    }
}
