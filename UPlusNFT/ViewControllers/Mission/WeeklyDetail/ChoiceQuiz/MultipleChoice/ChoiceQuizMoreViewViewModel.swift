//
//  ChoiceQuizMoreViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

final class ChoiceQuizMoreViewViewModel: MissionBaseModel {
    
//    @Published var imageUrls: [URL] = []
    var selectedButton: Int?
    @Published var buttonStatus: [Bool] = []
    
    override init(type: Type, mission: Mission, numberOfWeek: Int = 0) {
        super.init(type: type, mission: mission, numberOfWeek: numberOfWeek)
        
//        self.getImageUrls()
    }
    
}

extension ChoiceQuizMoreViewViewModel {
//    private func getImageUrls() {
//        Task {
//            do {
//                let imagePaths = mission.missionContentImagePaths ?? []
//                var imageUrls: [URL] = []
//                for imagePath in imagePaths {
//                    imageUrls.append(try await FirebaseStorageManager.shared.getDataUrl(reference: imagePath))
//                }
//                self.imageUrls = imageUrls
//            }
//            catch {
//                print("Error downloading image url -- \(error)")
//            }
//        }
//    }
    
    
}
