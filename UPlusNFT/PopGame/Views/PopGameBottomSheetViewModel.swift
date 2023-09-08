//
//  BottomSheetViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/24.
//

import Foundation
import Combine
import DifferenceKit

final class PopGameBottomSheetViewModel {
    
    public private(set) var firstListVM: LeaderBoardFirstSectionCellListViewModel
    public private(set) var secondListVM: LeaderBoardSecondSectionCellListViewModel
    
    @Published var changeset: StagedChangeset<[ArraySection<SectionID, AnyDifferentiable>]> = []
    @Published var isLoaded: Bool = false
    
    init(
        firstListVM: LeaderBoardFirstSectionCellListViewModel,
        secondListVM: LeaderBoardSecondSectionCellListViewModel
    ) {
        self.firstListVM = firstListVM
        self.secondListVM = secondListVM
    }
    
    @Published var source: [ArraySection<SectionID, AnyDifferentiable>] = []
    
    func getInitialItems(of collectionType: CollectionType, gameType: GameType) {
        
        Task {
            
            var firstSectionOldVal = self.firstListVM.leaderBoardFirstSectionVMList
            var secondSectionOldVal = self.secondListVM.leaderBoardVMList
            
            let typedErasedFirstSectionOldVal = firstSectionOldVal.map {
                return AnyDifferentiable($0)
            }
            let typedErasedSecondSectionOldVal = secondSectionOldVal.map {
                return AnyDifferentiable($0)
            }
            
            self.source = [
                ArraySection(model: .first, elements: typedErasedFirstSectionOldVal),
                ArraySection(model: .second, elements: typedErasedSecondSectionOldVal)
            ]
            
            var firstSectionNewVal: [LeaderBoardFirstSectionCellViewModel] = []
            async let firstSectionVM = self.firstListVM.getFirstSectionVM(of: collectionType, gameType: gameType)
            
            
            var secondSectionNewVal: [LeaderBoardSecondSectionCellViewModel] = []
            async let secondSectionVM = self.secondListVM.getSecondSectionVM(of: collectionType, gameType: gameType)
            
            guard let firstVM = try await firstSectionVM else {
                print("First Section VM Returned")
                return
                
            }
            firstSectionOldVal.append(firstVM)
            firstSectionNewVal.append(firstVM)
            
            guard let secondVM = try await secondSectionVM else {
                print("Second Section VM Returned")
                return
                
            }
            secondSectionOldVal = secondVM
            secondSectionNewVal = secondVM
            
            let typedErasedFirstSectionNewVal = firstSectionNewVal.map {
                AnyDifferentiable($0)
            }
            
            let typedErasedSecondSectionNewVal = secondSectionNewVal.map {
                return AnyDifferentiable($0)
            }
//            print("Second Section New Val: \(typedErasedSecondSectionNewVal)")
            let target: [ArraySection<SectionID, AnyDifferentiable>] = [
                ArraySection(model: .first, elements: typedErasedFirstSectionNewVal),
                ArraySection(model: .second, elements: typedErasedSecondSectionNewVal)
            ]
            
            self.changeset = StagedChangeset(source: self.source, target: target)
            self.isLoaded = true
        }
        
    }
    
    func getCachedItems(of collectionType: CollectionType, gameType: GameType) async throws {
        
        var firstSectionOldVal = self.firstListVM.leaderBoardFirstSectionVMList
        var secondSectionOldVal = self.secondListVM.leaderBoardVMList
        
        let typedErasedFirstSectionOldVal = firstSectionOldVal.map {
            return AnyDifferentiable($0)
        }
        let typedErasedSecondSectionOldVal = secondSectionOldVal.map {
            return AnyDifferentiable($0)
        }
        
        self.source = [
            ArraySection(model: .first, elements: typedErasedFirstSectionOldVal),
            ArraySection(model: .second, elements: typedErasedSecondSectionOldVal)
        ]
        
        var firstSectionNewVal: [LeaderBoardFirstSectionCellViewModel] = []
        async let firstSectionVM = self.firstListVM.getFirstSectionVM(of: collectionType, gameType: gameType)
        
        var secondSectionNewVal: [LeaderBoardSecondSectionCellViewModel] = []
        async let secondSectionVM = self.secondListVM.getCachedAddressSectionVM(of: collectionType, gameType: gameType)
        
        guard let firstVM = try await firstSectionVM else { return }
        firstSectionOldVal.append(firstVM)
        firstSectionNewVal.append(firstVM)
        
        guard let secondVM = try await secondSectionVM else { return }
        secondSectionOldVal = secondVM
        secondSectionNewVal = secondVM
        
        let typedErasedFirstSectionNewVal = firstSectionNewVal.map {
            AnyDifferentiable($0)
        }
        
        let typedErasedSecondSectionNewVal = secondSectionNewVal.map {
            return AnyDifferentiable($0)
        }
        
        let target: [ArraySection<SectionID, AnyDifferentiable>] = [
            ArraySection(model: .first, elements: typedErasedFirstSectionNewVal),
            ArraySection(model: .second, elements: typedErasedSecondSectionNewVal)
        ]
        
        self.changeset = StagedChangeset(source: self.source, target: target)
        
    }
    
}

