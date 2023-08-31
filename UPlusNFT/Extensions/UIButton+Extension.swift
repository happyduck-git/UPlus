//
//  UIButton+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import UIKit
import Combine

// MARK: - Set Underline
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
// MARK: - Combine Publisher
extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchUpInside)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: - Align Image and Text Vertically
extension UIButton {
    func alignVerticalCenter(padding: CGFloat = 10.0) {
        titleLabel?.textAlignment = .center
            guard let imageSize = imageView?.frame.size,
                  let titleText = titleLabel?.text,
                  let titleFont = titleLabel?.font else {
                return
            }
            
            let titleSize = (titleText as NSString).size(withAttributes: [.font: titleFont])
            
            let total = imageSize.height + titleSize.height + padding
            imageEdgeInsets = UIEdgeInsets(top: -(total - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
            titleEdgeInsets = UIEdgeInsets(top: 50, left: 0, bottom: -(total - titleSize.height), right: 0)
        }
}
