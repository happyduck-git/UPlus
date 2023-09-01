//
//  Date.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/27.
//

import Foundation

extension Date {
    static var nowString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: .init())
    }
}
