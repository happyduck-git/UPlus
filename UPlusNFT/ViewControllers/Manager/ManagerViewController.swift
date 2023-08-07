//
//  ManagerViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import UIKit

enum ManagerSection: String, CaseIterable {
    case dailyMission = "루틴미션"
    case weeklyMission = "여정미션"
}

final class ManagerViewController: UIViewController {

    let sections = ManagerSection.allCases
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.table)
        self.table.frame = view.bounds
        
        self.table.delegate = self
        self.table.dataSource = self
    }

}

extension ManagerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = self.sections[indexPath.row].rawValue
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = ManagerRoutineMissionViewController()
            self.show(vc, sender: self)
        }
    }
}
