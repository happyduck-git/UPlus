//
//  User.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/03.
//

import Foundation

struct User: Codable {
    let id: String
    let address: String
    let nickname: String?
    let profileImagePath: String?
    let profilePageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case address
        case nickname
        case profileImagePath = "profile_image_path"
        case profilePageUrl = "profile_page_url"
    }
}
