//
//  Date+Extention.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/03.
//

import Foundation

extension Date {
    var monthDayTimeFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        return dateFormatter.string(from: self)
    }
}
