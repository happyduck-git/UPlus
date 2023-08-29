//
//  CommentCountMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine
import Nuke

protocol CommentCountMissionViewControllerDelegate: AnyObject {
    func submitCommentDidTap()
}

final class CommentCountMissionViewController: UIViewController {

    //MARK: - Dependency
    private let vm: CommentCountMissionViewViewModel
    
    // MARK: - Delegate
    weak var delegate: CommentCountMissionViewControllerDelegate?
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.eventBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quizImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let weblinkButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.titleLabel?.lineBreakMode = .byTruncatingMiddle
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = MissionConstants.inputAnswer
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.recommend, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.gray02
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableHeaderView: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray07
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        return label
    }()
    
    private let commentTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(CommentCountMissionTableViewCell.self,
                       forCellReuseIdentifier: CommentCountMissionTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    //MARK: - Init
    init(vm: CommentCountMissionViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.hideKeyboardWhenTappedAround()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
//        self.commentTable.tableHeaderView = tableHeaderView
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bind()
        self.configure()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: Like 저장
        self.saveLikes()
    }
    
}

extension CommentCountMissionViewController {
    private func configure() {
        self.titleLabel.text = self.vm.mission.missionContentTitle
        
        switch self.vm.type {
        case .event:
            return
        case .weekly:
            if let html = vm.mission.missionContentText,
               let attributedString = vm.retrieveHtmlString(html: html) {
                self.weblinkButton.isHidden = false
                weblinkButton.setAttributedTitle(attributedString, for: .normal)
            }
        }

    }
}

// MARK: - Bind with ViewModel
extension CommentCountMissionViewController {
    
    private func bind() {
        
        func bindViewToViewModel() {
            
            self.vm.$imageUrls
                .receive(on: DispatchQueue.main)
                .sink { [weak self] urls in
                    guard let `self` = self,
                          let url = urls.first else { return }
                    self.spinner.startAnimating()
                    
                    Task {
                        do {
                            self.quizImageView.image = try await ImagePipeline.shared.image(for: url)
                            self.spinner.stopAnimating()
                        }
                        catch {
                            print("Error")
                        }
                    }
    
                }
                .store(in: &bindings)
            
            self.vm.$comment
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                    let comment = $0
                    else { return }
                    
                    let commentEmpty = comment.isEmpty
                    let interactive: Bool = commentEmpty ? false : true
                    let bgColor: UIColor = commentEmpty ? UPlusColor.gray02 : UPlusColor.mint03
                    let textColor: UIColor = commentEmpty ? .white : UPlusColor.gray08
                    
                    self.checkAnswerButton.isUserInteractionEnabled = interactive
                    self.checkAnswerButton.backgroundColor = bgColor
                    self.checkAnswerButton.setTitleColor(textColor, for: .normal)
                    
                }
                .store(in: &bindings)
            
            self.vm.$participated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    if $0 {
                        self.checkAnswerButton.isEnabled = false
                        self.checkAnswerButton.backgroundColor = UPlusColor.gray02
                        self.checkAnswerButton.setTitleColor(.white, for: .normal)
                        self.checkAnswerButton.setTitle("이미 참여하였습니다.", for: .normal)
                    }
                    
                }
                .store(in: &bindings)
            
            self.vm.$comments
                .receive(on: DispatchQueue.main)
                .sink { [weak self] comments in
                    guard let `self` = self else { return }
                    self.commentTable.reloadData()
                }
                .store(in: &bindings)

        }
        
        func bindViewModelToView() {
            self.weblinkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] urls in
                    guard let `self` = self else { return }
                    if let html = vm.mission.missionContentText {
                        vm.openURL(from: html)
                    }
                }
                .store(in: &bindings)
            
            self.textField.textPublisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] text in
                    guard let `self` = self else { return }
                        self.vm.comment = text
                }
                .store(in: &bindings)
            
            self.checkAnswerButton
                .tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let comment = self.vm.comment
                    else { return }
                    
                    do {
                        let user = try UPlusUser.getCurrentUser()
                        
                        let newComment = MissionComment(userId: user.userNickname,
                                                        commentText: comment,
                                                        likes: 0,
                                                        isLikedByCurrentUser: false)
                        self.vm.comments.append(newComment)

                        self.checkAnswerButton.isUserInteractionEnabled = false
                        self.checkAnswerButton.backgroundColor = .systemGray
                        
                        Task {
                            // TODO: Save comments
                            try await self.vm.saveEventParticipationStatus(selectedIndex: nil,
                                                                           recentComments: nil,
                                                                           comment: comment)
                            // Check level update.
                            try await self.vm.checkLevelUpdate()
                            
                        }
                        
                        self.delegate?.submitCommentDidTap()
                    }
                    catch {
                        UPlusLogger.logger.error("Error saving event participation status  -- \(String(describing: error))")
                    }
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

//MARK: - Set UI & Layout
extension CommentCountMissionViewController {
    private func setUI() {
        self.view.addSubviews(
            self.backgroundImage,
            self.titleLabel,
            self.spinner,
            self.quizImageView,
            self.weblinkButton,
            self.textField,
            self.checkAnswerButton,
            self.commentTable
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.quizImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1),
            self.quizImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizImageView.trailingAnchor, multiplier: 1),
            self.quizImageView.heightAnchor.constraint(equalToConstant: 200),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.quizImageView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.quizImageView.centerYAnchor),
            
            self.weblinkButton.topAnchor.constraint(equalToSystemSpacingBelow: self.quizImageView.bottomAnchor, multiplier: 1),
            self.weblinkButton.leadingAnchor.constraint(equalTo: self.quizImageView.leadingAnchor),
            self.weblinkButton.trailingAnchor.constraint(equalTo: self.quizImageView.trailingAnchor),
            
            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.weblinkButton.bottomAnchor, multiplier: 3),
            self.textField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.textField.trailingAnchor, multiplier: 2),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.textField.bottomAnchor, multiplier: 3),
            self.checkAnswerButton.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            self.checkAnswerButton.trailingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: 60),
            
            self.commentTable.topAnchor.constraint(equalToSystemSpacingBelow: self.checkAnswerButton.bottomAnchor, multiplier: 2),
            self.commentTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.commentTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.commentTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
    }
}

extension CommentCountMissionViewController {
    
    private func saveLikes() {
        self.vm.saveLikes()
    }
    
}

// MARK: - TableView Delegate & DataSource
extension CommentCountMissionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCountMissionTableViewCell.identifier,
                                                 for: indexPath) as? CommentCountMissionTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let comment = self.vm.comments[indexPath.row]
        
        cell.bind(with: self.vm, at: indexPath.row)
        cell.configure(image: "image",
                       nickname: comment.userId,
                       comment: comment.commentText,
                       likes: comment.likes,
                       isLiked: comment.isLikedByCurrentUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.comments.count / 2
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
