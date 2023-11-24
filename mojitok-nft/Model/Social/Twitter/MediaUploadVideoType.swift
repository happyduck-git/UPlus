//
//  MediaUploadVideoType.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/20.
//

struct MediaUploadVideoType: Codable {
    let videoType: String
    
    enum CodingKeys: String, CodingKey {
        case videoType = "video_type"
    }
}
