//
//  SVGView.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/25.
//

import UIKit

import Macaw

final class SVGView: MacawView {
    
    init(name: String) {
        super.init(frame: .zero)
        if let path = Bundle.main.path(forResource: name, ofType: "svg"),
           let node = try? SVGParser.parse(fullPath: path) {
            self.node = node
            self.contentMode = .scaleAspectFill
        }
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//    class SVGTigerView: MacawView {
//        required init?(coder aDecoder: NSCoder) {
//            super.init(node: try! SVGParser.parse(path: "tiger"), coder: aDecoder)
//        }
//    }
