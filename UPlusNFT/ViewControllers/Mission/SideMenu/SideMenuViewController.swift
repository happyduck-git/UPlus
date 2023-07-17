//
//  SideMenuViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

class SideMenuViewController: UIViewController {

    private let menuTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        menuTable.delegate = self
        menuTable.dataSource = self
    }

}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    private func setUI() {
        view.addSubview(menuTable)
        NSLayoutConstraint.activate([
            menuTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menuTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            menuTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            menuTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.image = UIImage(systemName: "heart.fill")
        config.text = "Menu #\(indexPath.row + 1)"
        cell.contentConfiguration = config
        
        return cell
    }
}
