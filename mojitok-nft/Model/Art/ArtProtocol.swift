//
//  ArtProtocol.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/26.
//

import UIKit

protocol ArtProtocol: Codable {
    var name: String { get }
    var fileName: String { get }
    var resource: Resource { get }
    var mediaType: MediaType { get }
    var createdAt: Int { get }
}
