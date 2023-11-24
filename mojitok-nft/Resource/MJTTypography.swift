//
//  MJTTypography.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import UIKit

struct MJTTypography {
    
    enum Roboto: String {
        case medium = "Roboto-Medium"
        case regular = "Roboto-Regular"
    }
    
    static let description = UIFont(name: Roboto.regular.rawValue, size: 11 * scale)
    
    static let header01 = UIFont(name: Roboto.regular.rawValue, size: 24 * scale)
    static let header02 = UIFont(name: Roboto.medium.rawValue, size: 24 * scale)
    
    static let subtitle01 = UIFont(name: Roboto.regular.rawValue, size: 20 * scale)
    static let subtitle02 = UIFont(name: Roboto.medium.rawValue, size: 22 * scale)
    
    static let body01 = UIFont(name: Roboto.regular.rawValue, size: 16 * scale)
    static let body02 = UIFont(name: Roboto.medium.rawValue, size: 18 * scale)
    static let body03 = UIFont(name: Roboto.medium.rawValue, size: 16 * scale)
    static let body04_d = UIFont(name: Roboto.medium.rawValue, size: 14 * scale)
    
    static let button01 = UIFont(name: Roboto.regular.rawValue, size: 12 * scale)
}

extension UIFont {
    static let description = MJTTypography.description
    
    static let header01 = MJTTypography.header01
    static let header02 = MJTTypography.header02
    
    static let subtitle01 = MJTTypography.subtitle01
    static let subtitle02 = MJTTypography.subtitle02
    
    static let body01 = MJTTypography.body01
    static let body02 = MJTTypography.body02
    static let body03 = MJTTypography.body03
    static let body04_d = MJTTypography.body04_d
    
    static let button01 = MJTTypography.button01
}
