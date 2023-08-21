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
        table.register(WeeklyOverViewTableViewCell.self,
                       forCellReuseIdentifier: WeeklyOverViewTableViewCell.identifier)
        table.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        table.translatesAutoresizingMaskIntoConstraints = false
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
        
        self.view.backgroundColor = UPlusColor.gray02
        
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
            
            self.vm.weeklyMissionCompletion
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 {
                        print("여정 완료")
              
                        let bottomVC = WeeklyMissionCompleteBottomSheetViewController(vm: self.vm)
                        bottomVC.modalPresentationStyle = .overCurrentContext
                        self.present(bottomVC, animated: false)
                    } else {
                        print("여정 미완료")
                    }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyOverViewTableViewCell.identifier, for: indexPath) as? WeeklyOverViewTableViewCell else {
            return UITableViewCell()
        }

        let mission = self.vm.weeklyMissions[indexPath.row]
        
        let hasParticipated = self.vm.missionParticipation[mission.missionId] ?? false
        let type: MissionStatus = hasParticipated ? .participated : .open
        cell.configure(type: type, mission: mission)
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .answerQuizPlural:
                let vm = AnswerQuizPluralViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = AnswerQuizPluralViewController(vm: vm)
                vc.delegate = self
                
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
                let vm = ChoiceQuizzOXViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizOXViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .choiceQuizMore:
                let vm = ChoiceQuizMoreViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizMoreViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)

            case .choiceQuizVideo:
                let vm = ChoiceQuizVideoViewViewModel(mission: mission, numberOfWeek: self.vm.week)
                let vc = ChoiceQuizVideoViewController(vm: vm)
                vc.delegate = self
                
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
                let vc = ContentReadOnlyMissionViewController(vm: vm, type: .weekly)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            default:
                break
            }
            
        } else if anyMission is PhotoAuthMission {
            let mission = anyMission as! PhotoAuthMission
            
            let vm = PhotoAuthQuizViewViewModel(mission: mission, numberOfWeek: self.vm.week)
            let vc = PhotoAuthQuizViewController(vm: vm)
            
            self.show(vc, sender: self)
        }
        
    }
}

extension WeeklyMissionOverViewViewController: BaseMissionViewControllerDelegate {
    func redeemDidTap(vc: BaseMissionViewController) {
        self.vm.getWeeklyMissionInfo(week: self.vm.week)
    }
}

extension WeeklyMissionOverViewViewController: BaseMissionScrollViewControllerDelegate {
    func redeemDidTap(vc: BaseMissionScrollViewController) {
        self.vm.getWeeklyMissionInfo(week: self.vm.week)
    }
}

