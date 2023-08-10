//
//  ChoiceQuizMoreViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

final class ChoiceQuizMoreViewViewModel {
    let mission: ChoiceQuizMission
    
    @Published var imageUrls: [URL] = []
    
    init(mission: ChoiceQuizMission) {
        self.mission = mission
        self.getImageUrls()
    }
}

extension ChoiceQuizMoreViewViewModel {
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
