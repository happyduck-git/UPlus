//
//  InventoryServiceProtocol.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/26.
//

import Foundation

protocol InventoryServiceProtocol {
    
    func saveImage(data: Data) -> ArtProtocol
}
