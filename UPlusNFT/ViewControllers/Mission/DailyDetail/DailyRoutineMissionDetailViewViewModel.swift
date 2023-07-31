//
//  DailyRoutineMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit.UIImage
import Combine

final class DailyRoutineMissionDetailViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    /* Athlete Mission */
    @Published var athleteMissions: [AthleteMission] = []
    
    @Published var selectedImage: UIImage?
}

extension DailyRoutineMissionDetailViewViewModel {
    
    func getAtheleteMissions() {
        Task {
            do {
                self.athleteMissions = try await self.firestoreManager.getAthleteMission()
            }
            catch {
                print("Error fetching athelete missions -- \(error)")
            }
        }
    }
    
    /*
    func getUserParticipation() {
        self.athleteMissions.filter { mission in
            guard let userStateMap = mission.missionUserStateMap,
                  let participation = userStateMap["user-index"]
            else { return false }
            
        }
    }
    */
}
