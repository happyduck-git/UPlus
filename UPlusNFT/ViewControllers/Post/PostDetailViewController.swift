//
//  PostDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit

final class PostDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: PostTableViewCellModel
    
    // MARK: - UI Elements
    private let postImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let postTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        
        setUI()
        setLayout()
        setDelegate()
    }
    
    // MARK: - Init
    init(vm: PostTableViewCellModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.configure(with: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(
            postImage,
            postTitle,
            commentTable
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
//            self.postImage.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
//            self.postImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
//            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImage.trailingAnchor, multiplier: 2),
            
            self.postTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.postTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postTitle.trailingAnchor, multiplier: 3),
            
            self.commentTable.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitle.bottomAnchor, multiplier: 2),
            self.commentTable.leadingAnchor.constraint(equalTo: self.postTitle.leadingAnchor),
            self.commentTable.trailingAnchor.constraint(equalTo: self.postTitle.trailingAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentTable.bottomAnchor, multiplier: 2)
        ])
        
        self.postTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setDelegate() {
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
    }
    
    private func configure(with vm: PostTableViewCellModel) {
        self.postTitle.text = vm.postContent
    }
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        guard let comment = vm.comments?[indexPath.row] else {
            return cell
        }
        var config = cell.defaultContentConfiguration()
        config.text = comment.commentContentText
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: show recomments per comment
        guard let comment = vm.comments?[indexPath.row] else { return }
        
        let commentId = comment.commentId
        Task {
            do {
                try await FirestoreManager.shared.getRecomments(
                    postId: comment.postId,
                    commentId: commentId
                )
            }
            catch {
                print("Error getting comments -- \(error.localizedDescription)")
            }
        }
    }
}
