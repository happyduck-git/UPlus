//
//  ManagerEventMissionViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/08.
//

import UIKit

final class ManagerEventMissionViewController: UIViewController {

    private let missionIds: [Int] = Array(0...35)
    private var selectedId: String = ""
    
    private let missionFormatType: [MissionFormatType] = MissionFormatType.allCases
    private var selectedFormatType: MissionFormatType?
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var saveButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("저장", for: .normal)
        btn.backgroundColor = .systemOrange
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(saveBtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.view.addSubviews(self.pickerView,
                              self.saveButton)
        NSLayoutConstraint.activate([
            self.pickerView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.pickerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pickerView.trailingAnchor, multiplier: 2),
            self.pickerView.heightAnchor.constraint(equalToConstant: 100),
            
            self.saveButton.topAnchor.constraint(equalToSystemSpacingBelow: self.pickerView.bottomAnchor, multiplier: 2),
            self.saveButton.centerXAnchor.constraint(equalTo: self.pickerView.centerXAnchor)
        ])
    }
  
}

extension ManagerEventMissionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.missionIds.count
        } else {
            return self.missionFormatType.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.selectedId = String(describing: self.missionIds[row])
            print("Selected Id: \(self.selectedId)")
        } else {
            self.selectedFormatType = self.missionFormatType[row]
            print("Selected Mission: \(self.selectedFormatType?.rawValue)")
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(describing: self.missionIds[row])
        } else {
            return self.missionFormatType[row].rawValue
        }
        
    }
}

extension ManagerEventMissionViewController {
    @objc
    private func saveBtnDidTap() {
        do {
            guard let selectedType = self.selectedFormatType else { return }
            switch selectedType {
            case .governanceElection:
                let choices: [[String]] = [
                    ["선택지#1", "선택지#2"],
                    ["선택지#1", "선택지#2", "선택지#3"],
                    ["선택지#1", "선택지#2", "선택지#3", "선택지#4"],
                    ["선택지#1", "선택지#2", "선택지#3", "선택지#4", "선택지#5"]
                ]
                
                try FirestoreManager.shared.createEventMission(
                    missionId: self.selectedId,
                    rewardPoint: 1,
                    formatType: .governanceElection,
                    subFormatType: .governanceElection,
                    governanceElectionCaptions: choices[Int.random(in: choices.startIndex...choices.endIndex)],
                    avatarLevel: 0,
                    creationTime: Date()
                )
            case .shareMediaOnSlack:
                try FirestoreManager.shared.createEventMission(
                    missionId: self.selectedId,
                    rewardPoint: 2,
                    formatType: .shareMediaOnSlack,
                    subFormatType: .shareMediaOnSlack,
                    governanceElectionCaptions: nil,
                    avatarLevel: 0,
                    creationTime: Date()
                )
            case .commentCount:
                try FirestoreManager.shared.createEventMission(
                    missionId: self.selectedId,
                    rewardPoint: 2,
                    formatType: .commentCount,
                    subFormatType: .commentCount,
                    governanceElectionCaptions: nil,
                    avatarLevel: 0,
                    creationTime: Date()
                )
            case .contentReadOnly:
                try FirestoreManager.shared.createEventMission(
                    missionId: self.selectedId,
                    rewardPoint: 2,
                    formatType: .contentReadOnly,
                    subFormatType: .contentReadOnly,
                    governanceElectionCaptions: nil,
                    avatarLevel: 0,
                    creationTime: Date()
                )
            default:
                break
            }
            
        }
        catch {
            print("Error saving event missions -- \(error)")
        }
    }
}
