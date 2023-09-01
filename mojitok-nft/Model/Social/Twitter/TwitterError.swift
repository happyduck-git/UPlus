//
//  TwitterError.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/27.
//

import Foundation

struct TwitterError: Codable {
    let errors: [TwitterErrorCase]
}


struct TwitterErrorCase: Codable {
    let code: Int
    let message: String
}
