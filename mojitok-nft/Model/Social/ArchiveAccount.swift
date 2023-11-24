//
//  ArchiveAccount.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/23.
//

struct ArchiveAccount: Codable, SocialAccountProtocol {
    let id: String
    let token: Token
    let name: String
}
