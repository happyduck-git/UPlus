//
//  ChoiceQuizVideoViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation
import Combine

final class ChoiceQuizVideoViewViewModel {
    
    let mission: ChoiceQuizMission
    
    @Published var imageUrls: [URL] = []
    
    //MARK: - Init
    init(mission: ChoiceQuizMission) {
        self.mission = mission
        self.getImageUrls()
    }
    
}

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

