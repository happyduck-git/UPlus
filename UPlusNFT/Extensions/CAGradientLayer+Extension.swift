//
//  CAGradientLayer+Extension.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/27.
//

import QuartzCore
import UIKit.UIColor

extension CAGradientLayer {
    
    func makeGradientLayer(colors: [UIColor]) {
        self.colors = colors
        self.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.endPoint = CGPoint(x: 1.0, y: 1.0)
    }
    
}
