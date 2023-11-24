//
//  Token.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/23.
//

import Foundation

struct Token: Codable {
    let kind: TokenKind
    let tokenData: Data
}
