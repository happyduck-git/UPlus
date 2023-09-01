//
//  TwitterAccount.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/03.
//

import Foundation

struct TwitterAccount: SocialAccountProtocol {
    let id: String
    let token: Token
    let name: String
}

extension TwitterAccount {
    var accessTokenWithSecret: AccessTokenWithSecret? {
        if let token = try? JSONDecoder().decode(AccessTokenWithSecret.self, from: token.tokenData) {
            return token
        }
        return nil
    }
}
