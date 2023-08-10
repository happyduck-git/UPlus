//
//  ContentReadOnlyMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class ContentReadOnlyMissionViewViewModel {
    
    let mission: ContentReadOnlyMission
    let numberOfWeek: Int
    
    @Published var imageUrls: [URL] = []
    
    init(mission: ContentReadOnlyMission, numberOfWeek: Int) {
        self.mission = mission
        self.numberOfWeek = numberOfWeek
        
        self.getImageUrls()
    }
}

extension ContentReadOnlyMissionViewViewModel {
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
