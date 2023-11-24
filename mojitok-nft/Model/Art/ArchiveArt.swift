//
//  ArchiveArt.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/23.
//

import Foundation

struct ArchiveArt: ArtProtocol {
    let name: String
    let fileName: String
    let resource: Resource
    let mediaType: MediaType
    let createdAt: Int
}
