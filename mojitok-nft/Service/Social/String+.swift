//
//  String+.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/25.
//

import Foundation

extension String {
    var urlEncoded: String {
//        var charset: CharacterSet = .urlQueryAllowed
//        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
//        return self.addingPercentEncoding(withAllowedCharacters: charset)!
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
    
    var urlQueryStringParameters: Dictionary<String, String> {
        var params = [String: String]()
        let items = self.split(separator: "&")
        for item in items {
            let combo = item.split(separator: "=")
            if combo.count == 2 {
                let key = "\(combo[0])"
                let val = "\(combo[1])"
                params[key] = val
            }
        }
        return params
    }
}
