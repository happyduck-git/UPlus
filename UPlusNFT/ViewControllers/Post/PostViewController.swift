//
//  PostViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit

final class PostViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.text = "Entry View Controller"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        
        setUI()
        setLayout()
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(
        titleLabel
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
