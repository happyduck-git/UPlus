//
//  PostDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit
import Combine

final class PostDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: PostDetailViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let postImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let postImageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .systemGray6
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
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
        
        vm.fetchPostMetaData(vm.postId)
        bind()
        
    }
    
    // MARK: - Init
    init(vm: PostDetailViewViewModel) {
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
            postImageLabel,
            metadataLabel,
            postTitle,
            commentTable
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            /*
            self.postImage.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.postImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImage.trailingAnchor, multiplier: 2),
            self.postImage.heightAnchor.constraint(equalToConstant: 200),
            */
            self.postImageLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.postImageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageLabel.trailingAnchor, multiplier: 2),
            self.postTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageLabel.bottomAnchor, multiplier: 2),
            self.postTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postTitle.trailingAnchor, multiplier: 3),
            
            self.metadataLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitle.bottomAnchor, multiplier: 2),
            self.metadataLabel.leadingAnchor.constraint(equalTo: self.postTitle.leadingAnchor),
            self.metadataLabel.trailingAnchor.constraint(equalTo: self.postTitle.trailingAnchor),
            
            self.commentTable.topAnchor.constraint(equalToSystemSpacingBelow: self.metadataLabel.bottomAnchor, multiplier: 2),
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
    
    private func bind() {
        
        func bindViewToViewModel() {
            
        }
        
        func bindViewModelToView() {
            vm.$metaData
                .receive(on: DispatchQueue.main)
                .sink { [weak self] metadata in
                guard let data = metadata else {
                    self?.metadataLabel.text = "Meta data found to be NIL."

                    return
                }
                    self?.metadataLabel.text = "\(data.configuration.beginTime)"
            }
            .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    private func configure(with vm: PostDetailViewViewModel) {
        self.postTitle.text = "Text Content: " + vm.postContent
        guard let imageList = vm.imageList,
           !imageList.isEmpty else {
            self.postImageLabel.isHidden = true
            return
        }
        
        self.postImageLabel.text = "Images: " + String(describing: imageList)
    }
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = vm.comments,
              !rows.isEmpty
        else {
            return 1
        }
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
//            return UITableViewCell()
//        }
//
//        cell.configure(with: <#T##CommentTableViewCellModel#>)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        guard let comments = vm.comments,
              !comments.isEmpty
        else {
            config.text = "아직 댓글이 없습니다!"
            cell.contentConfiguration = config
            return cell
        }
        
        config.text = comments[indexPath.row].commentContentText
        
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
                    postId: vm.postId,
                    commentId: commentId
                )
            }
            catch {
                print("Error getting comments -- \(error.localizedDescription)")
            }
        }
    }
}
