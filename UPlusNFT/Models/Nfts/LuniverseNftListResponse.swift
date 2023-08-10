//
//  LuniverseNftListResponse.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

struct LuniverseNftListResponse: Decodable {
    let code: String
    let data: LuniverseNftListData
}

struct LuniverseNftListData: Decodable {
    let items: [LuniverseNftItem]
}

struct LuniverseNftItem: Decodable {
    let tokenId: String
}
