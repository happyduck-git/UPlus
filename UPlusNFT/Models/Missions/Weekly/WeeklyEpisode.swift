//
//  WeeklyEpisode.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/28.
//

import Foundation

enum WeeklyEpisode {
    case week1
    case week2
    case week3
    
    var background: String {
        switch self {
        case .week1:
            return ImageAssets.episode1Wall
        case .week2:
            return ImageAssets.episode2Wall
        case .week3:
            return ImageAssets.episode3Wall
        }
    }
    
    var footerImage: String {
        switch self {
        case .week1:
            return ImageAssets.episode1Footer
        case .week2:
            return ImageAssets.episode2Footer
        case .week3:
            return ImageAssets.episode3Footer
        }
    }
    
    var episodeSubTitle: String {
        switch self {
        case .week1:
            return ImageAssets.episode1Sub
        case .week2:
            return ImageAssets.episode2Sub
        case .week3:
            return ImageAssets.episode3Sub
        }
    }
    
    var episodeTitle: String {
        switch self {
        case .week1:
            return ImageAssets.episode1Title
        case .week2:
            return ImageAssets.episode2Title
        case .week3:
            return ImageAssets.episode3Title
        }
    }
    
    var episodeDescription: String {
        switch self {
        case .week1:
            return MissionConstants.episode1Desc
        case .week2:
            return MissionConstants.episode2Desc
        case .week3:
            return MissionConstants.episode3Desc
        }
    }
    
    var episodeEmptyPiece: String {
        switch self {
        case .week1:
            return ImageAssets.episode1Empty
        case .week2:
            return ImageAssets.episode2Empty
        case .week3:
            return ImageAssets.episode3Empty
        }
    }
    
}
