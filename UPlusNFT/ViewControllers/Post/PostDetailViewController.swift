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
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .blue
        view.bounces = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        scrollContentView.addSubviews(
            postIdLabel,
            postUrlLabel,
            postTypeLabel,
            postTitleLabel,
            horizontalLineView,
            postContentTextView,
            postImageView,
            profileImageView,
            nicknameLabel,
            likeButton,
            createdAtLabel,
            commentTable
        )
    }
    
    private func setLayout() {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            self.scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            self.scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            self.scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            self.scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            
        ])

        NSLayoutConstraint.activate([
            self.postIdLabel.topAnchor.constraint(equalToSystemSpacingBelow: scrollContentView.topAnchor, multiplier: 1),
            self.postIdLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollContentView.leadingAnchor, multiplier: 3),
            self.postUrlLabel.topAnchor.constraint(equalTo: self.postIdLabel.topAnchor),
            scrollContentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postUrlLabel.trailingAnchor, multiplier: 3),

            self.postTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postIdLabel.bottomAnchor, multiplier: 2),
            self.postTypeLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),

            self.postTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTypeLabel.bottomAnchor, multiplier: 1),
            self.postTitleLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),

            self.horizontalLineView.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitleLabel.bottomAnchor, multiplier: 3),
            self.horizontalLineView.heightAnchor.constraint(equalToConstant: 2),
            self.horizontalLineView.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollContentView.leadingAnchor, multiplier: 4),
            scrollContentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.horizontalLineView.trailingAnchor, multiplier: 3),

            self.postContentTextView.topAnchor.constraint(equalToSystemSpacingBelow: self.horizontalLineView.bottomAnchor, multiplier: 2),
            self.postContentTextView.leadingAnchor.constraint(equalTo: self.horizontalLineView.leadingAnchor),
            self.postContentTextView.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.postContentTextView.heightAnchor.constraint(equalToConstant: viewHeight / 5),

            self.postImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 2),
            self.postImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollContentView.leadingAnchor, multiplier: 3),
            self.postImageView.heightAnchor.constraint(equalToConstant: viewHeight / 4),
            scrollContentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageView.trailingAnchor, multiplier: 3),

            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageView.bottomAnchor, multiplier: 2),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.profileImageView.heightAnchor.constraint(equalToConstant: viewWidth / 16),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),

            self.nicknameLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),

            self.createdAtLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
            self.createdAtLabel.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.likeButton.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),

            self.commentTable.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 2),
            self.commentTable.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor),
            self.commentTable.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor),
            self.commentTable.heightAnchor.constraint(equalToConstant: viewHeight / 2),
            
            self.scrollContentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentTable.bottomAnchor, multiplier: 2)


            /*
             self.postImage.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
             self.postImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
             self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImage.trailingAnchor, multiplier: 2),
             self.postImage.heightAnchor.constraint(equalToConstant: 200),

             self.postImageLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
             self.postImageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
             self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageLabel.trailingAnchor, multiplier: 2),
             self.postTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageLabel.bottomAnchor, multiplier: 2),
             self.postTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
             self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postTitleLabel.trailingAnchor, multiplier: 3),

             self.metadataLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitleLabel.bottomAnchor, multiplier: 2),
             self.metadataLabel.leadingAnchor.constraint(equalTo: self.postTitleLabel.leadingAnchor),
             self.metadataLabel.trailingAnchor.constraint(equalTo: self.postTitleLabel.trailingAnchor),
            */

        ])
        
//        self.postTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setDelegate() {
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        self.scrollView.delegate = self
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
            cell.backgroundColor = .systemGray4
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

extension PostDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//
//        if scrollView == self.scrollView {
//            let navHeight = navigationController?.navigationBar.frame.height ?? 0.0
//            if yOffset >= 0.0 && yOffset == (commentTable.frame.minY - navHeight*2) {
//                print("Yoffset: \(yOffset)")
//                scrollView.isScrollEnabled = false
//            }
//        }
//
//        if scrollView == self.commentTable && self.commentTable.contentOffset.y <= 0.0 {
//            print("Triggered")
//            commentTable.isScrollEnabled = false
//            scrollView.isScrollEnabled = true
//        }
        
        if scrollView == self.scrollView {
                    let yOffset = scrollView.contentOffset.y
            print("MaxY: \(scrollView.frame.maxY)")
        }
        if scrollView == self.commentTable {
            print("Comment table")
        }
        
        let bottomEdge = self.scrollView.contentOffset.y + self.scrollView.frame.size.height
        let tableViewBottom = commentTable.frame.origin.y + commentTable.frame.size.height
        
        if bottomEdge > tableViewBottom {
            // Scroll view reached the bottom of the table view
            commentTable.isScrollEnabled = true
        } else {
            // Scroll view is not at the bottom of the table view
            commentTable.isScrollEnabled = false
        }
        
        if commentTable.contentOffset.y < 0 {
            print("Commenttalbe ; \(commentTable.contentOffset.y)")
            commentTable.isScrollEnabled = false
        }
    }
    
}
