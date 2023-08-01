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
    
    var yearMonthDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    var monthDayFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd"
        return dateFormatter.string(from: self)
    }
    
}
