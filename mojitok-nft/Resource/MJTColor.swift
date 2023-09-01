//
//  MJTColor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import UIKit

struct MJTColor {
    static let mojitokBlue: UIColor = .init(hex: 0x3278FF)
    static let bg: UIColor = .init(hex: 0x141318)
    static let white01: UIColor = .init(hex: 0xFFFFFF)
    
    static let grey01: UIColor = .init(hex: 0xCDCDCD)
    static let grey02: UIColor = .init(hex: 0x363636)
    static let grey03: UIColor = .init(hex: 0x4E4E4E)
    static let grey04: UIColor = .init(hex: 0xA1A1A1)
    static let grey05: UIColor = .init(hex: 0x656565)
    
    static let twitter: UIColor = .init(hex: 0x1D9BF0)
}

extension UIColor {
    static let mojitokBlue = MJTColor.mojitokBlue
    static let bg = MJTColor.bg
    static let white01 = MJTColor.white01
    
    static let grey01 = MJTColor.grey01
    static let grey02 = MJTColor.grey02
    static let grey03 = MJTColor.grey03
    static let grey04 = MJTColor.grey04
    static let grey05 = MJTColor.grey05
    
    static let twitter = MJTColor.twitter
}
