//
//  String+Extension.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/30.
//

import Foundation

extension String {
    
    /// Slice a String by the last "/" mark.
    /// - Returns: String after "/" mark.
    func extractAfterSlash() -> String? {
        let components = self.split(separator: "/")
        return components.last.map { String($0) }
    }

}
