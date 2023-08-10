//
//  WeeklyMissionOverViewViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import UIKit
import Combine

final class WeeklyMissionOverViewViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WeeklyMissionOverViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let header: WeeklyMissionOverViewTableViewHeader = {
        let header = WeeklyMissionOverViewTableViewHeader()
        return header
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "여정 미션"
    }
    
    // MARK: - Init
    init(vm: WeeklyMissionOverViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.setUI()
        self.setDelegate()
        self.bind()
        
        self.header.configure(with: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind with View Model
extension WeeklyMissionOverViewViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.$weeklyMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.tableView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionOverViewViewController {
    private func setUI() {
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        
        self.header.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 3)
        self.tableView.tableHeaderView = self.header
    }
    
    private func setDelegate() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WeeklyMissionOverViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.weeklyMissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        // 1. Check if user has participated a cetain mission
        let mission = self.vm.weeklyMissions[indexPath.row]
        let hasParticipated = self.vm.missionParticipation[mission.missionId] ?? false
        var config = cell.defaultContentConfiguration()
        
        if hasParticipated {
            config.text = "참여 완료"
        } else {
            config.text = String(describing: mission.missionSubFormatType) + " : " + String(describing: mission.missionRewardPoint) + MissionConstants.pointUnit
        }
        cell.contentConfiguration = config
        
        return cell
    }

}

extension WeeklyMissionOverViewViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "UPLUS 알아가기"
    }
}

extension WeeklyMissionOverViewViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let anyMission = self.vm.weeklyMissions[indexPath.row]
        
        if anyMission is ShortAnswerQuizMission {
            let mission = anyMission as! ShortAnswerQuizMission
            
            guard let subFormatType = MissionSubFormatType(rawValue: mission.missionSubFormatType) else {
                return
            }
            switch subFormatType {
            
            case .answerQuizSingular:
                let vm = AnswerQuizSingularViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = AnswerQuizSingularViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            case .answerQuizPlural:
                let vm = AnswerQuizPluralViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = AnswerQuizPluralViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            default:
                break
            }
            
        } else if anyMission is ChoiceQuizMission {
            let mission = anyMission as! ChoiceQuizMission
            
            guard let subFormatType = MissionSubFormatType(rawValue: mission.missionSubFormatType) else {
                return
            }
            switch subFormatType {
    
            case .choiceQuizOX:
                let vm = ChoiceQuizzOXViewViewModel(dataSource: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizOXViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .choiceQuizMore:
                let vm = ChoiceQuizMoreViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizMoreViewController(vm: vm)
                
                self.show(vc, sender: self)

            case .choiceQuizVideo:
                let vm = ChoiceQuizVideoViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizVideoViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            default:
                break
            }
            
        } else if anyMission is ContentReadOnlyMission {
            let mission = anyMission as! ContentReadOnlyMission
            
            guard let subFormatType = MissionSubFormatType(rawValue: mission.missionSubFormatType) else {
                return
            }
            
            switch subFormatType {
            case .contentReadOnly:
                let vm = ContentReadOnlyMissionViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ContentReadOnlyMissionViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            default:
                break
            }
            
            
//            Task {
//                do {
//                    try await FirestoreManager.shared.saveParticipatedWeeklyMission(
//                        questionId: mission.missionId,
//                        week: 1,
//                        today: Date().yearMonthDateFormat,
//                        missionType: .weeklyQuiz1,
//                        point: mission.missionRewardPoint,
//                        state: .successed)
//                    print("MissionContentTitle: \(String(describing: mission.missionContentTitle))")
//                }
//                catch {
//                    print("Error saving weekly mission -- \(error)")
//                }
//            }
        }
        
/*
//        let mission = self.vm.missions[indexPath.row]
        // 1. Check if user has participated a cetain mission
        let hasParticipated = self.vm.missionParticipation[mission.missionId] ?? false
        // 1-1. If so, ban selection.
        if hasParticipated {
            return
        } else {
            // 1-2. If not, allow selection.
            let anytype = MissionFormatType(rawValue: anyMission.missionFormatType)
            
            let missionType = MissionFormatType(rawValue: mission.missionFormatType)
            
            let cellVM = WeeklyMissionDetailViewViewModel(dataSource: mission,
                                                          numberOfWeek: self.vm.numberOfWeek)
            self.navigationController?.modalPresentationStyle = .overCurrentContext
            
            switch missionType {
            case .choiceQuiz:
                let vc = WeeklyChoiceQuizMissionDetailViewController(vm: cellVM)
                vc.delegate = self
                self.show(vc, sender: self)
            case .answerQuiz:
                let vc = WeeklyAnswerQuizMissionDetailViewController(vm: cellVM)
                self.show(vc, sender: self)
            default:
                break
            }
 
        }
 */
    }
}

extension WeeklyMissionOverViewViewController: ChoiceQuizOXViewControllerDelegate {
    func answerDidSaved() {
        self.vm.getWeeklyMissionInfo(week: self.vm.week)
    }
}
