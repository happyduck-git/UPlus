//
//  UITextView+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/29.
//

import UIKit
import Combine

extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .compactMap(\.text)
            .eraseToAnyPublisher()
    }
}
