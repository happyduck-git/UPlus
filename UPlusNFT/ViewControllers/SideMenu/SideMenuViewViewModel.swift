//
//  SideMenuViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import Foundation

final class SideMenuViewViewModel {
    
    enum MenuType: Int, CaseIterable {
        case home
        case wallet
        case rankBoard
        case notice
    }
    
    private let menuList: [MenuType: String] = [
        .home: ImageAsset.home,
        .wallet: ImageAsset.wallet,
        .rankBoard: ImageAsset.ranking,
        .notice: ImageAsset.notice
    ]
    
    func numberOfMenu() -> Int {
        return menuList.count
    }
    
    func getMenu(of type: MenuType) -> [String: String] {
        var key: String = ""
        switch type {
        case .home:
            key = SideMenuConstants.home
        case .wallet:
            key = SideMenuConstants.wallet
        case .rankBoard:
            key = SideMenuConstants.rankBoard
        case .notice:
            key = SideMenuConstants.notice
        }
        return [key: self.menuList[type] ?? "n/a"]
    }
    
    func getMenu(of section: Int) -> (title: String, image: String) {
        
        let type = MenuType.allCases.filter {
            $0.rawValue == section
        }.first
        
        guard let sectionType = type else {
            return ("no menu", "no image")
        }
        
        var key: String = ""
        switch type {
        case .home:
            key = SideMenuConstants.home
        case .wallet:
            key = SideMenuConstants.wallet
        case .rankBoard:
            key = SideMenuConstants.rankBoard
        default:
            key = SideMenuConstants.resetPassword
        }
        
        return (key, self.menuList[sectionType] ?? "n/a")
    }
}