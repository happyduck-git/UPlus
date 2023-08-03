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
            self.vm.$missions
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
        return self.vm.missions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        let vm = self.vm.missions[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = String(describing: vm.missionFormatType) + " : " + String(describing: vm.missionRewardPoint) + MissionConstants.pointUnit
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
        
        let vm = self.vm.missions[indexPath.row]
        let missionType = MissionFormatType(rawValue: vm.missionFormatType)
        
        let cellVM = WeeklyMissionDetailViewViewModel(dataSource: vm,
                                                      numberOfWeek: self.vm.numberOfWeek)
        self.navigationController?.modalPresentationStyle = .overCurrentContext
        
        switch missionType {
        case .choiceQuiz:
            let vc = WeeklyChoiceQuizMissionDetailViewController(vm: cellVM)
            self.present(vc, animated: true)
        case .answerQuiz:
            let vc = WeeklyAnswerQuizMissionDetailViewController(vm: cellVM)
            self.present(vc, animated: true)
        default:
            break
        }
    }
}
