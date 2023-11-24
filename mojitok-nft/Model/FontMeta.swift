//
//  FontMeta.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/28.
//

import Foundation

struct FontMeta: Codable {
    let name: String
    let version: Int
}

extension FontMeta: Equatable {
    static  func ==(lhs: FontMeta, rhs: FontMeta) -> Bool {
        return lhs.name == rhs.name
    }
}

extension FontMeta {
    var fileURL: URL {
        FontService.fontFolderURL.appendingPathComponent(name)
    }
    
}
