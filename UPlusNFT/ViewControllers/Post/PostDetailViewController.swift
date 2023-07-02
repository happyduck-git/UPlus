//
//  PostDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit
import Combine

final class PostDetailViewController: UIViewController {
    
    enum PostType: String {
        case article = "일반 게시물"
        case multipleChoice = "객관식"
        case bestComment = "베스트 댓글"
    }
    
    // MARK: - Dependency
    private let vm: PostDetailViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements

    private let postIdLabel: UILabel = {
        let label = UILabel()
        label.text = "123194"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postUrlLabel: UILabel = {
        let label = UILabel()
        label.text = "http://platfarm.net/post/92"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.text = PostType.article.rawValue
        label.textColor = .white
        label.backgroundColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "게시글 타이틀입니다."
        label.textColor = .black
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let horizontalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postContentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /* 미사용 삭제 예정 */
    private let postImageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "이미지가 없습니다."
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "nickname"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setTitle("99", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "2023/07/01"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /* 미사용 삭제 예정 */
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .systemGray6
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray4
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.register(PostDetailTableViewCell.self, forCellReuseIdentifier: PostDetailTableViewCell.identifier)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setLayout()
        setDelegate()
        setNavigationBar()
        
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
        view.addSubview(commentTable)
    }
    
    private func setLayout() {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width

        NSLayoutConstraint.activate([
            self.commentTable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.commentTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.commentTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.commentTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func setDelegate() {
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
    }
    
    private func setNavigationBar() {
        if vm.isPostOfCurrentUser {
            let menu = UIMenu(children: [
                UIAction(title: "수정하기", handler: { action in
                    print(action.title)
                    //                    self.showEditVC()
                }),
                UIAction(title: "삭제하기", attributes: .destructive, handler: { action in
                    self.showDeleteUIAlert()
                }),
            ])
            
            let btn = UIButton()
            btn.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
            btn.showsMenuAsPrimaryAction = true
            btn.menu = menu
            let barbutton = UIBarButtonItem(customView: btn)
            navigationItem.rightBarButtonItem = barbutton
        }
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
        self.postContentTextView.text = "게시글 본문: " + vm.postContent
        guard let imageList = vm.imageList,
              !imageList.isEmpty else {
            //            self.postImageLabel.isHidden = true
            self.postImageLabel.text = "Images: 이미지가 없는 게시글입니다."
            return
        }
        
        self.postImageLabel.text = "Images: " + String(describing: imageList)
    }
    
    private func showDeleteUIAlert() {
        let alert = UIAlertController(title: "게시글 삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "삭제", style: .default) { _ in
            
            // TODO: Add Delete Post logic (also delete images inside Storage)
            
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = vm.numberOfSections()
        return count == 1 ? 2 : count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if section == 0 {
            return 1
        } else {
            // TODO: Recomment count에 따라 변동.
            print("Section showing: \(section)")
            guard let cellVM = vm.viewModelForRow(at: section - 1)
            else { return 1 }
            
            if cellVM.isOpened {
                print("Number of rows in section #\(section) --- \((self.vm.recomments[section]?.count ?? 0) + 1)")
                return (self.vm.recomments[section]?.count ?? 0) + 1
            }
            else {
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let firstSectionCell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as? PostDetailTableViewCell else { return UITableViewCell() }
            
            firstSectionCell.configure(with: vm)
            return firstSectionCell
            
        } else {
            
            
            guard let otherSectionCell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
                return UITableViewCell()
            }
            otherSectionCell.resetCell()
            
            if indexPath.row == 0 {
                guard let cellVM = vm.viewModelForRow(at: indexPath.section - 1)
                else {
                    let defaultCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                    var config = defaultCell.defaultContentConfiguration()
                    config.text = "아직 댓글이 없습니다!"
                    defaultCell.contentConfiguration = config
                    return defaultCell
                }
                
                otherSectionCell.configure(with: cellVM)
                
                return otherSectionCell
            }
            else {
                guard let recomments = self.vm.recomments[indexPath.section],
                      !recomments.isEmpty
                else {
                    let defaultCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
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
                otherSectionCell.backgroundColor = .systemGray4
                otherSectionCell.configure(with: cellVM)
                return otherSectionCell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Section tapped \(indexPath.section)")
        if indexPath.section != 0 && indexPath.row == 0 {
            guard let cellVM = vm.viewModelForRow(at: indexPath.section - 1) else { return }
            cellVM.isOpened = !cellVM.isOpened
            
            self.vm.fetchRecomment(at: indexPath.section, of: cellVM.id)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return view.frame.height / 2
        } else {
            return view.frame.height / 10
        }
    }
    
}

