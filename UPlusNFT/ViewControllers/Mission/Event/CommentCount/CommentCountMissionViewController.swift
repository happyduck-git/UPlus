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

final class CommentCountMissionViewController: BaseScrollViewController {

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
        imageView.image = UIImage(named: ImageAssets.eventBackground)
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

    private let quizLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.contentMode = .scaleAspectFit
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let txtField = UITextField()
        txtField.borderStyle = .none
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let hintLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.registerComment, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.gray02
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let additionalInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let additionalInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UPlusColor.gray01
        label.clipsToBounds = true
        label.layer.cornerRadius = 8.0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray07
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
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

        self.hideKeyboardWhenTappedAround()
        
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
            let map = self.vm.mission.missionContentExtraMap ?? [:]
            
            let content = self.vm.mission.missionContentText ?? ""
            let hint = map[FirestoreConstants.middleDescription] ?? ""
            let bottom = map[FirestoreConstants.bottomDescription] ?? ""

            self.quizLabel.attributedText = self.vm.retrieveHtmlString(html: content)
            self.hintLabel.attributedText = self.vm.retrieveHtmlString(html: hint)
            self.additionalInfoLabel.attributedText = self.vm.retrieveHtmlString(html: bottom)
            
            self.totalNumberLabel.text = String(format: MissionConstants.numOfParticipants, self.vm.comments.count)
            print("Comments: \(self.vm.comments.count)")
        case .weekly:
            return
        }

    }
}

// MARK: - Bind with ViewModel
extension CommentCountMissionViewController {
    
    private func bind() {
        
        func bindViewToViewModel() {
            
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
                    
                    self.saveComment(comment)
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
        self.canvasView.addSubviews(
            self.backgroundImage,
            self.titleLabel,
            self.spinner,
            self.quizLabel,
            self.textField,
            self.hintLabel,
            self.checkAnswerButton,
            self.additionalInfoContainer,
            self.additionalInfoLabel,
            self.totalNumberLabel,
            self.commentTable
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.canvasView.topAnchor, multiplier: 3),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.quizLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 3),
            self.quizLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: canvasView.leadingAnchor, multiplier: 1),
            canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizLabel.trailingAnchor, multiplier: 1),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.quizLabel.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.quizLabel.centerYAnchor),

            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.quizLabel.bottomAnchor, multiplier: 4),
            self.textField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.textField.trailingAnchor, multiplier: 2),
            
            self.hintLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.textField.bottomAnchor, multiplier: 1),
            self.hintLabel.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.hintLabel.bottomAnchor, multiplier: 3),
            self.checkAnswerButton.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            self.checkAnswerButton.trailingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: 60),
            
            self.additionalInfoContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.checkAnswerButton.bottomAnchor, multiplier: 3),
            self.additionalInfoContainer.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.additionalInfoContainer.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            
            self.additionalInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.additionalInfoContainer.topAnchor, multiplier: 2),
            self.additionalInfoLabel.leadingAnchor.constraint(equalTo: self.checkAnswerButton.leadingAnchor),
            self.additionalInfoLabel.trailingAnchor.constraint(equalTo: self.checkAnswerButton.trailingAnchor),
            self.additionalInfoContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.additionalInfoLabel.bottomAnchor, multiplier: 2),
            
            self.totalNumberLabel.topAnchor.constraint(equalTo: self.additionalInfoContainer.bottomAnchor),
            self.totalNumberLabel.heightAnchor.constraint(equalToConstant: 50),
            self.totalNumberLabel.leadingAnchor.constraint(equalTo: self.commentTable.leadingAnchor),
            self.totalNumberLabel.trailingAnchor.constraint(equalTo: self.commentTable.trailingAnchor),
            
            self.commentTable.topAnchor.constraint(equalTo: self.totalNumberLabel.bottomAnchor),
            self.commentTable.heightAnchor.constraint(equalToConstant: 400),
            self.commentTable.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.commentTable.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.commentTable.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        
        self.textField.delegate = self
    }
}

// MARK: - Private
extension CommentCountMissionViewController {
    
    private func saveComment(_ comment: String) {
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
    
    private func saveLikes() {
        self.vm.saveLikes()
        
        // TODO: 좋아요 1번은 점수 부여
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

extension CommentCountMissionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.setTextFieldUnderline(color: UPlusColor.mint04)
    }
}
