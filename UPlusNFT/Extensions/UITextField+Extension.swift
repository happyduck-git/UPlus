//
//  UITextField+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/21.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .compactMap(\.text)
            .eraseToAnyPublisher()
    }
}

extension UITextField {
    func setTextFieldUnderline(color: UIColor) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 2)
        underline.backgroundColor = color.cgColor
        self.layer.addSublayer(underline)
    }
}
