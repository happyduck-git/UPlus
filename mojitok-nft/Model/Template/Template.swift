//
//  Template.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/25.
//

import Foundation

struct Template: Codable {
    let name: String
    let version: Int
    let appVersion: Int
    let lottieFileName: String
    var thumbnailImageName: String
    let isRelease: Bool
    let collectionName: String?
    let isMock: Bool
    let isPurchase: Bool
    let description: String
    let twitterForm: String?
    
    enum CodingKeys: String, CodingKey {
        case name, version, appVersion, isRelease, collectionName, isMock, isPurchase, description, twitterForm
        case lottieFileName = "lottieFile"
        case thumbnailImageName = "thumbnailImage"
    }
}

extension Template: Equatable {
    static  func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Template {
    var fileURL: URL {
        TemplateService.templateFolderURL.appendingPathComponent(lottieFileName)
    }
    
    var thumbnailURL: URL {
        TemplateService.templateFolderURL.appendingPathComponent(thumbnailImageName)
    }
    
    func updateDic(keys: [String], dic: [String: String]) -> [String: String] {
        var result: [String: String] = [:]
        for key in keys {
            if key.contains(",") {
                let values = key.split(separator: ",")
                let originKey = String(values[0])
                if let count = Int(values[1]) {
                    result[key] = dic[originKey]?.cutOfRange(length: count)
                } else {
                    result[key] = dic[key]
                }
            } else {
                result[key] = dic[key]
            }
        }
        return result
    }
}
