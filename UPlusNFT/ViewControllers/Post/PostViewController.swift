//
//  PostViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit
import FirebaseAuth

final class PostViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        let rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logOutDidTap))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "메인화면"
        view.backgroundColor = .tertiarySystemBackground
        
        setUI()
        setLayout()
        
        let username = Auth.auth().currentUser?.displayName ?? "no username"
        greetings(to: username)
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(titleLabel)
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func greetings(to username: String) {
        let fullText = "Welcome \(username)!\nEntry View Controller"
        let range = (fullText as NSString).range(of: username)
        let color = UIColor.systemPink
        
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        titleLabel.attributedText = attributedString
    }
    
    @objc
    private func logOutDidTap() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }
        catch {
            print("Error logout user \(error.localizedDescription)")
        }
    }
    
}
