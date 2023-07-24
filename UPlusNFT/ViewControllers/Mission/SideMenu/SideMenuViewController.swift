//
//  SideMenuViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

protocol SideMenuViewControllerDelegate: AnyObject {
    func menuTableViewController(controller: SideMenuViewController, didSelectRow selectedRow: Int)
}

final class SideMenuViewController: UIViewController {

    // MARK: - Dependency
    private let vm: SideMenuViewViewModel
    
    // MARK: - Delegate
    weak var delegate: SideMenuViewControllerDelegate?
    
    // MARK: - UI Elements
    private let menuTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Init
    init(vm: SideMenuViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUI()
        self.menuTable.delegate = self
        self.menuTable.dataSource = self
    }

}

// MARK: - TableView Delegate & DataSource
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    private func setUI() {
        view.addSubview(menuTable)
        NSLayoutConstraint.activate([
            self.menuTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.menuTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.menuTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.menuTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.numberOfMenu()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        let menu = self.vm.getMenu(of: indexPath.item)
        
        config.image = UIImage(systemName: menu.image)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        config.text = menu.title
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuTableViewController(controller: self, didSelectRow: indexPath.row)
    }
}
