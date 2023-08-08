//
//  DailyRoutineMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit.UIImage
import Combine

protocol DailyRoutineMissionDetailViewViewModelDelegate: AnyObject {
    func didRecieveMission()
}

final class DailyRoutineMissionDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Delegate
    weak var delegate: DailyRoutineMissionDetailViewViewModelDelegate?
    
    // MARK: - DataSource
    var missionType: MissionType
    @Published var selectedImage: UIImage?
    
    /* Athlete Mission */
    @Published var athleteMissions: [AthleteMission] = []
    
    // MARK: - Init
    init(missionType: MissionType) {
        self.missionType = missionType
    }
    
}

extension DailyRoutineMissionDetailViewViewModel {
    
    func getAtheleteMissions() {
        Task {
            do {
                self.athleteMissions = try await self.firestoreManager.getAthleteMission()
                self.delegate?.didRecieveMission()
            }
            catch {
                print("Error fetching athelete missions -- \(error)")
            }
        }
    }
    
    func saveRoutineParticipation() {
        /*
        Task {
            do {
                self.firestoreManager.saveDailyMissionPhoto(userIndex: <#T##Int64#>, missionType: <#T##MissionType#>, image: <#T##Data#>)
            }
            catch {
            }
        }
         */
    }
}
