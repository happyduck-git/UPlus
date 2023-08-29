//
//  String+Extension.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/30.
//

import Foundation

extension String {
    func extractAfterSlash() -> String? {
        let components = self.split(separator: "/")
        return components.last.map { String($0) }
    }

}
