//
//  ManagerMissionViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ManagerRoutineMissionViewController: UIViewController {

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .automatic
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
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

        title = "루틴 미션"
        self.view.backgroundColor = .white
        
        self.view.addSubviews(self.datePicker,
                              self.saveButton)
        
        NSLayoutConstraint.activate([
            self.datePicker.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.datePicker.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.datePicker.trailingAnchor, multiplier: 2),
            self.datePicker.heightAnchor.constraint(equalToConstant: 100),
            
            self.saveButton.topAnchor.constraint(equalToSystemSpacingBelow: self.datePicker.bottomAnchor, multiplier: 2),
            self.saveButton.centerXAnchor.constraint(equalTo: self.datePicker.centerXAnchor)
        ])
        
    }

    @objc
    private func handleDatePicker(_ sender: UIDatePicker) {
        print(sender.date.yearMonthDateFormat)
    }
    
    @objc
    private func saveBtnDidTap() {
        do {
            try FirestoreManager.shared.createRoutineMission(date: self.datePicker.date,
                                                         rewardPoint: 1,
                                                         startTime: Date(),
                                                         formatType: .photoAuth,
                                                         subTopicType: .dailyExpAthlete,
                                                         topicType: .dailyExp,
                                                         avatarLevel: 0)
        }
        catch {
            print("Error saving missions -- \(error)")
        }
    }
}

extension ManagerRoutineMissionViewController {
    private func saveDailyMission() {
        
    }
}
