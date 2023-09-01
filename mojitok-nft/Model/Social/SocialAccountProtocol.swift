//
//  SocialAccountProtocol.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/03.
//

protocol SocialAccountProtocol: Codable {
    var id: String { get }
    var token: Token { get }
    var name: String { get }
}
