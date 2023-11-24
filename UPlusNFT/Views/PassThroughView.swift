//
//  PassThroughView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/31.
//

import UIKit

class PassThroughView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }

}
