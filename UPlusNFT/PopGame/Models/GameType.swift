//
//  GameType.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/09/04.
//

import Foundation

enum GameType: String {
    case popgame
}

enum CollectionType: String {
    case uplus = "start_up_master"
    
    var firestoreDocName: String {
        switch self {
        case .uplus:
            return "start_up_master"
        }
    }
}
