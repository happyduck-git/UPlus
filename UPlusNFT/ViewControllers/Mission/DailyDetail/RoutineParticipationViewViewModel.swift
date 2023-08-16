//
//  RoutineParticipationViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import Foundation
import Combine

final class RoutineParticipationViewViewModel {
    let mission: any Mission
    
    init(mission: any Mission) {
        self.mission = mission
    }
}
