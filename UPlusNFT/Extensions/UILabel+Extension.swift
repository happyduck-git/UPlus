//
//  UILabel+Extension.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/01.
//

import UIKit

extension UILabel {
    func limitTextLength(maxLength: Int) {
        guard let originalText = self.text else {
            return
        }
        
        if originalText.count > maxLength {
            let truncatedText = String(originalText.prefix(maxLength))
            self.text = truncatedText
        }
    }
}
