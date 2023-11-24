//
//  SideMenuViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit
import FirebaseAuth
import Combine

protocol SideMenuViewControllerDelegate: AnyObject {
    func menuTableViewController(controller: SideMenuViewController, didSelectRow selectedRow: Int)
    func resetPasswordDidTap()
    func signOutDidTap()
}

final class SideMenuViewController: UIViewController {

    // MARK: - Dependency
    private let vm: SideMenuViewViewModel

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
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
        button.setTitle(SideMenuConstants.resetPassword, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle(SideMenuConstants.logout, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return button
    }()
    
    private lazy var agreementButton: UIButton = {
        let button = UIButton()
        button.setTitle(SideMenuConstants.agreement, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
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
        self.setLayout()
        self.bind()
        
        self.menuTable.delegate = self
        self.menuTable.dataSource = self
    }

}

// MARK: - Bind
extension SideMenuViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            self.resetPasswordButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.openResetPasswordVC()
                    
                }
                .store(in: &bindings)
            
            self.logoutButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.userLogOut()
                    
                }
                .store(in: &bindings)
            
            self.agreementButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    //TODO: 개인정보수집동의 관련 action 설정 필요
                    
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Private
extension SideMenuViewController {
    
    @objc private func openResetPasswordVC() {
        self.delegate?.resetPasswordDidTap()
    }
    
    @objc private func userLogOut() {
        self.delegate?.signOutDidTap()
    }
    
}

// MARK: - TableView Delegate & DataSource
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    private func setUI() {
        view.addSubviews(self.menuTable,
                         self.resetPasswordButton,
                         self.logoutButton,
                         self.agreementButton)
    }
    
    private func setLayout() {
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
            self.logoutButton.bottomAnchor.constraint(equalTo: self.agreementButton.topAnchor),
            
            self.agreementButton.leadingAnchor.constraint(equalTo: self.resetPasswordButton.leadingAnchor),
            self.agreementButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 20),
            
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.agreementButton.bottomAnchor, multiplier: 3)
            
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

extension SideMenuViewController: LogOutBottomSheetViewControllerDelegate {
    func signOutDidTap() {
//        self.delegate?.signOutDidTap()
    }
}
