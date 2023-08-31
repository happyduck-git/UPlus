//
//  ChoiceQuizMoreViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

final class ChoiceQuizMoreViewViewModel: MissionBaseModel {
    
    @Published var selectedButton: Int?
    @Published var buttonStatus: [Bool] = []

}
