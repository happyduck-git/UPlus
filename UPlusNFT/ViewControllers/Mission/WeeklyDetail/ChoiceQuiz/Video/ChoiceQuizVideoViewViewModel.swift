//
//  ChoiceQuizVideoViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation
import Combine

final class ChoiceQuizVideoViewViewModel: MissionBaseModel {
    
    
    
    @Published var imageUrls: [URL] = []
    
    var videoId: String = ""
    
    
    var buttonStatus: [Bool] = []
    var selectedButton: Int?
    
    //MARK: - Init
    override init(type: Type, mission: Mission, numberOfWeek: Int = 0) {
        super.init(type: type, mission: mission, numberOfWeek: numberOfWeek)
        
        self.getImageUrls()
    }
    
}

// MARK: - Get Image Urls
extension ChoiceQuizVideoViewViewModel {
    private func getImageUrls() {
        Task {
            do {
                let imagePaths = mission.missionContentImagePaths ?? []
                var imageUrls: [URL] = []
                for imagePath in imagePaths {
                    imageUrls.append(try await FirebaseStorageManager.shared.getDataUrl(reference: imagePath))
                }
                self.imageUrls = imageUrls
            }
            catch {
                print("Error downloading image url -- \(error)")
            }
        }
    }
}
