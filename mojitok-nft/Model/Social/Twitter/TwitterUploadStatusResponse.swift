//
//  TwitterUploadStatusResponse.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/07/11.
//

import Foundation

struct TwitterUploadStatusResponse: Codable {
    enum Status {
        case success
        case fail
        case processing
    }
    let media_id: Int
    let media_id_string: String
    let expires_after_secs: Int
    let video: TwitterUploadStatusVideo?
    let processing_info: TwitterUploadStatusProcessingInfo
    
    var status: Status {
        if video != nil {
            return .success
        } else if processing_info.state == "in_progress" {
            return .processing
        } else {
            return .fail
        }
    }
}

struct TwitterUploadStatusProcessingInfo: Codable {
    let state: String
    let check_after_secs: Int?
    let progress_percent: Int
    let error: TwitterUploadStatusProcessingError?

}

struct TwitterUploadStatusProcessingError: Codable {
    let code: Int
    let name: String
    let message: String
}


struct TwitterUploadStatusVideo: Codable {
    let video_type: String
}
