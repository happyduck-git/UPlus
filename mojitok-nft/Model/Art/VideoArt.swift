//
//  VideoArt.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/26.
//

import Foundation
import UIKit

struct VideoArt: ArtUIProtocol {
    let name: String
    let fileName: String
    let resource: Resource
    var mediaType: MediaType = .video
    let createdAt: Int
    var data: Data? {
        let url = InventoryService.videoCacheFolderURL.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    var thumbnailImage: UIImage? {
        let url = InventoryService.videoCacheFolderURL.appendingPathComponent(name + ".jpg")
        if let data = try? Data(contentsOf: url) {
             return UIImage(data: data)
        }
        return nil
    }
}
