//
//  ChoiceQuizVideoViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation
import Combine

final class ChoiceQuizVideoViewViewModel: MissionBaseModel {
    
    // MARK: - Video
    var isVideoScreen: Bool = true
    
    var videoUrl: String = ""
    var secondLeft: String = ""
    
    var frontBottom: String = ""
    var rearTop: String = ""
    
    // MARK: - Submit Button
    @Published var isActivated: Bool = false
    @Published var nextDidTap: Bool = false
    var isRightAnswerSubmitted = PassthroughSubject<Bool, Never>()
    
    // MARK: - Quiz Button
    var buttonStatus: [Bool] = []
    var selectedButton: Int?
    
}


extension ChoiceQuizVideoViewViewModel {

}
