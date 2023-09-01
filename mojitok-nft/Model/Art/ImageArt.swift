//
//  ImageArt.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/26.
//

import Foundation
import UIKit

struct ImageArt: ArtUIProtocol {
    let name: String
    let fileName: String
    let resource: Resource
    let mediaType: MediaType = .image
    let createdAt: Int
    var data: Data? {
        let url = InventoryService.imageCacheFolderURL.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    
    var thumbnailImage: UIImage? {
        let url = InventoryService.imageCacheFolderURL.appendingPathComponent(name + ".jpg")
        if let data = try? Data(contentsOf: url) {
             return UIImage(data: data)
        }
        return nil
    }
}
