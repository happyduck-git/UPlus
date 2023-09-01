//
//  MediaUploadInitResponse.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/20.
//

struct MediaUploadInitResponse: Codable {
    let mediaID: Int
    let mediaIDString: String
    let expiresAfterSecs: Int
    
    enum CodingKeys: String, CodingKey {
        case mediaID = "media_id"
        case mediaIDString = "media_id_string"
        case expiresAfterSecs = "expires_after_secs"
    }
}
