//
//  MJTImage.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/14.
//

import UIKit

struct MJTImage {
    let name: String
    
    var image: UIImage? {
        return .init(named: name)
    }
}

extension MJTImage {
    static let menu: MJTImage = .init(name: "Icon_Menu")
    
    static let wallet: MJTImage = .init(name: "Icon_Wallet")
    static let setting: MJTImage = .init(name: "Icon_Setting")
    
    static let back: MJTImage = .init(name: "Icon_Back")
    static let x: MJTImage = .init(name: "Icon_X")
    static let plus: MJTImage = .init(name: "Icon_Plus")
    
    static let forward: MJTImage = .init(name: "Icon_Forward")
    static let video: MJTImage = .init(name: "Icon_Video")
    static let image: MJTImage = .init(name: "Icon_Image")
    
    static let play: MJTImage = .init(name: "Icon_Play")
    
    // Button Icon
    static let save: MJTImage = .init(name: "Icon_Save")
    static let twitter: MJTImage = .init(name: "Icon_Twitter")
    static let upload: MJTImage = .init(name: "Icon_Upload")
    static let instagram: MJTImage = .init(name: "Icon_Instagram")
    static let whatsApp: MJTImage = .init(name: "Icon_WhatsApp")
    static let facebook: MJTImage = .init(name: "Icon_Facebook")
    static let check: MJTImage = .init(name: "Icon_Check")
}
