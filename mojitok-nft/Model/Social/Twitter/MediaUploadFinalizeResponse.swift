//
//  MediaUploadFinalizeResponse.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/20.
//

struct MediaUploadFinalizeResponse: Codable {
    let mediaID: Int
    let mediaIDString: String
    let size: Int
    let expiresAfterSecs: Int
    let video: MediaUploadVideoType?
    let image: MediaUploadImageType?
    
    enum CodingKeys: String, CodingKey {
        case mediaID = "media_id"
        case mediaIDString = "media_id_string"
        case expiresAfterSecs = "expires_after_secs"
        case size, video, image
    }
}
