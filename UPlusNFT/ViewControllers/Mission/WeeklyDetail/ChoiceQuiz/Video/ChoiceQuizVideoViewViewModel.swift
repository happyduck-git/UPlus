//
//  ChoiceQuizVideoViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation
import Combine

final class ChoiceQuizVideoViewViewModel: WeeklyQuizBaseModel {
    
    @Published var imageUrls: [URL] = []
    var buttonStatus: [Bool] = []
    var selectedButton: Int?
    
    //MARK: - Init
    override init(mission: Mission, numberOfWeek: Int) {
        super.init(mission: mission, numberOfWeek: numberOfWeek)
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

