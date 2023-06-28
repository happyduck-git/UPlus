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
            
            vm.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.commentTable.reloadData()
                }
                .store(in: &bindings)
            
            vm.$recomments
                .receive(on: DispatchQueue.main)
                .sink { [weak self] recomment in
                    print("Recomment -- \(recomment)")
                    self?.commentTable.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = vm.numberOfSections()
        return count == 0 ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let count = vm.numberOfRows()
        //        return count == 0 ? 1 : count
        
        // TODO: Recomment count에 따라 변동.
        guard let cellVM = vm.viewModelForRow(at: section)
        else { return 1 }
        
        if cellVM.isOpened {
            print("Number of rows in section #\(section) --- \((self.vm.recomments[section]?.count ?? 0) + 1)")
            return (self.vm.recomments[section]?.count ?? 0) + 1
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }
        cell.resetCell()
        
        if indexPath.row == 0 {
            guard let cellVM = vm.viewModelForRow(at: indexPath.section)
            else {
                var config = defaultCell.defaultContentConfiguration()
                config.text = "아직 댓글이 없습니다!"
                defaultCell.contentConfiguration = config
                return defaultCell
            }
            
            cell.configure(with: cellVM)
           
            return cell
        }
        else {
            guard let recomments = self.vm.recomments[indexPath.section],
                  !recomments.isEmpty
            else {
                // recomment == nil || recomment is empty
                var config = defaultCell.defaultContentConfiguration()
                config.text = "아직 대댓글이 없습니다!"
                defaultCell.contentConfiguration = config
                defaultCell.backgroundColor = .systemGray4
                return defaultCell
            }
            // recomment != nil nor empty
            let recomment = recomments[indexPath.row - 1]
            let cellVM = CommentTableViewCellModel(
                id: recomment.recommentId,
                comment: recomment.recommentContentText,
                imagePath: nil,
                likeUserCount: nil,
                recomments: nil
            )
            cell.contentView.backgroundColor = .systemGray4
            cell.configure(with: cellVM)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            guard let cellVM = vm.viewModelForRow(at: indexPath.section) else { return }
            cellVM.isOpened = !cellVM.isOpened
            
            self.vm.fetchRecomment(at: indexPath.section, of: cellVM.id)
        }
    }

}
