//
//  ContentReadOnlyMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class ContentReadOnlyMissionViewViewModel: WeeklyBaseModel {
    
    //MARK: - Dependency
    private let storageManager = FirebaseStorageManager.shared
    
    @Published var imageUrls: [URL] = []
    
    override init(mission: Mission, numberOfWeek: Int) {
        super.init(mission: mission, numberOfWeek: numberOfWeek)
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
                    imageUrls.append(try await self.storageManager.getDataUrl(reference: imagePath))
                }
                self.imageUrls = imageUrls
            }
            catch {
                print("Error downloading image url -- \(error)")
            }
        }
    }
}
