//
//  MediaUploadImageType.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/20.
//

struct MediaUploadImageType: Codable {
    let imageType: String
    
    enum CodingKeys: String, CodingKey {
        case imageType = "image_type"
    }
}
