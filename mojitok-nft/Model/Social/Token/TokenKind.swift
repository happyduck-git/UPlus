//
//  TokenKind.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/03.
//

enum TokenKind: String, Codable {
    case accessToken = "AccessToken"
    case accessTokenWithSecret = "AccessTokenWithSecret"
    case oAuth = "OAuth"
    case jwt = "JWT"
}
