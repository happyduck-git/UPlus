//
//  BackToLoginViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import UIKit

final class BackToLoginViewController: UIViewController {
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backToLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle(ResetPasswordConstants.login, for: .normal)
        button.addTarget(self, action: #selector(backToLoginDidTap), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        
        setUI()
        setLayout()
    }
    
    // MARK: - Init
    init(desc: String) {
        super.init(nibName: nil, bundle: nil)
        descriptionLabel.text = desc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubview(descriptionLabel)
        view.addSubview(backToLoginButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10),
            descriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: descriptionLabel.trailingAnchor, multiplier: 3),
            
            backToLoginButton.topAnchor.constraint(equalToSystemSpacingBelow: descriptionLabel.bottomAnchor, multiplier: 2),
            backToLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func backToLoginDidTap() {
        let vcs = self.navigationController?.viewControllers
        let loginVC = vcs?.first { vc in
            vc.isKind(of: LoginViewController.self)
        }
        guard let vc = loginVC else { return }
        navigationController?.popToViewController(vc, animated: true)
    }
}
