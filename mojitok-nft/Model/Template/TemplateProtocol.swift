//
//  TemplateProtocol.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/08.
//

import UIKit

protocol TemplateProtocol {
    var name: String { get }
    var lottieFileName: String { get }
    var thumbnailImageString: String { get }
}

extension TemplateProtocol {
    var thumbnailImage: UIImage? {
        return .init(named: thumbnailImageString)
    }
}
