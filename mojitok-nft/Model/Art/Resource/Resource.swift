//
//  Resource.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/03.
//

import Foundation

struct Resource: Codable {
    let marketPlaceKind: MarketPlaceKind
    let address: String
    let mediaType: MediaType
    let nft: OpenSeaSimpleNFT
    let data: Data
    let permalink: String
    let template: Template
}
