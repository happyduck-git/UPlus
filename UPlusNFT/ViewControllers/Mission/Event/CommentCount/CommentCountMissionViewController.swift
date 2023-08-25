//
//  CommentCountMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine

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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        button.setTitle("추천하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentTable: UITableView = {
        let table = UITableView()
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
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bind()
        
        self.titleLabel.text = self.vm.mission.missionContentTitle
        self.quizLabel.text = self.vm.mission.missionContentText
    }

}

extension CommentCountMissionViewController {
    
    private func bind() {
        do {
            let user = try UPlusUser.getCurrentUser()
            
            self.vm.$participated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    if $0 {
                        self.checkAnswerButton.isEnabled = false
                        self.checkAnswerButton.backgroundColor = .systemGray
                        self.checkAnswerButton.setTitle("이미 참여하였습니다.", for: .normal)
                    }
                    
                }
                .store(in: &bindings)
            
            self.vm.$comments
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.commentTable.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.$combinations
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let imageCount = $0["ImageUrls"] as? [URL]
                    
               
                    
                    /*
                    self.label.text = "ImageUrls: \(imageCount?.count ?? 0)개\n\n"
                    + "Comments: \($0["comments"])\n\n"
                    + "commentCountMap: \($0["commentCountMap"])"
                     */
                }
                .store(in: &bindings)

            self.checkAnswerButton // Point 바로 수여X
                .tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let text = textField.text
                    else { return }
                    
                    self.vm.comment = text
                    self.vm.comments.append(contentsOf: [user.userNickname, text])
                    let val = self.vm.commentCountMap[text] ?? 0
                    self.vm.commentCountMap[text] = val + 1
                    
                    self.checkAnswerButton.isEnabled = false
                    self.checkAnswerButton.backgroundColor = .systemGray
                    
                    Task {
                        print("Task called")
                        do {
                            try await self.vm.saveEventParticipationStatus(selectedIndex: nil,
                                                                           recentComments: self.vm.comments,
                                                                           comment: text)
                            // Check level update.
                            try await self.vm.checkLevelUpdate()
                        }
                        catch {
                            UPlusLogger.logger.error("Error saving event participation status  -- \(String(describing: error))")
                        }
                    }
                    
                    self.delegate?.submitCommentDidTap()
                }
                .store(in: &bindings)
        }
        catch {
         print("Error getting user info from UserDefaults -- \(error)")
        }
  
    }
    
}

//MARK: - Set UI & Layout
extension CommentCountMissionViewController {
    private func setUI() {
        self.view.addSubviews(
            self.titleLabel,
            self.quizLabel,
            self.textField,
            self.checkAnswerButton,
            self.commentTable
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.quizLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.quizLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizLabel.trailingAnchor, multiplier: 2),
            
            
            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.quizLabel.bottomAnchor, multiplier: 3),
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

extension CommentCountMissionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCountMissionTableViewCell.identifier,
                                                 for: indexPath) as? CommentCountMissionTableViewCell else {
            return UITableViewCell()
        }
      
        let nickname = self.vm.comments[indexPath.row * 2]
        let comment = self.vm.comments[(indexPath.row * 2) + 1]
        
        cell.configure(image: "image", nickname: nickname, comment: comment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.comments.count / 2
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
