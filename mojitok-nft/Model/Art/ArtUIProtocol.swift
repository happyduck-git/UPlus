//
//  ArtUIProtocol.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/23.
//

import UIKit

protocol ArtUIProtocol: ArtProtocol {
    var data: Data? { get }
    var thumbnailImage: UIImage? { get }
}
