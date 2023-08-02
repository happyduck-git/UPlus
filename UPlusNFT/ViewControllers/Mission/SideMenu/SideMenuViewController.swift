//
//  SideMenuViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit
import FirebaseAuth

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
        table.isScrollEnabled = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(openResetPasswordVC), for: .touchUpInside)
        button.setTitle(SideMenuConstants.resetPassword, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setUnderline(1.0)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(userLogOut), for: .touchUpInside)
        button.setTitle(SideMenuConstants.logout, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setUnderline(1.0)
        return button
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

extension SideMenuViewController {
    @objc private func openResetPasswordVC() {
        let vc = EditUserInfoViewController()
        self.show(vc, sender: self)
    }
    
    @objc private func userLogOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            let alert = UIAlertController(title: "로그아웃 실패", message: "로그아웃에 실패하였습니다. 잠시 후 다시 시도해주세요.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(action)
            
            self.present(alert, animated: true)
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    private func setUI() {
        view.addSubviews(self.menuTable,
                         self.resetPasswordButton,
                         self.logoutButton)
        
        NSLayoutConstraint.activate([
            self.menuTable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.menuTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.menuTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.menuTable.bottomAnchor.constraint(equalTo: self.resetPasswordButton.topAnchor),
            
            self.resetPasswordButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.menuTable.leadingAnchor, multiplier: 2),
            self.resetPasswordButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 20),
            self.resetPasswordButton.bottomAnchor.constraint(equalTo: self.logoutButton.topAnchor),
            
            self.logoutButton.leadingAnchor.constraint(equalTo: self.resetPasswordButton.leadingAnchor),
            self.logoutButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 20),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.logoutButton.bottomAnchor, multiplier: 3)
            
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.numberOfMenu()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        let menu = self.vm.getMenu(of: indexPath.item)
        
        config.image = UIImage(named: menu.image)
        config.text = menu.title
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuTableViewController(controller: self, didSelectRow: indexPath.row)
    }
}
