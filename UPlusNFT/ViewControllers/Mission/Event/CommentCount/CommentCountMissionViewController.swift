//
//  CommentCountMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine

final class CommentCountMissionViewController: UIViewController {

    //MARK: - Dependency
    private let vm: CommentCountMissionViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .systemGray6
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = "댓글입력해주세요."
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()

    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("댓글입력!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        self.bind()
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
                        self.submitButton.isEnabled = false
                        self.submitButton.backgroundColor = .systemGray
                        self.submitButton.setTitle("이미 참여하였습니다.", for: .normal)
                    }
                    
                }
                .store(in: &bindings)
            
            self.vm.$combinations
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let imageCount = $0["ImageUrls"] as? [URL]
                    
                    self.label.text = "ImageUrls: \(imageCount?.count ?? 0)개\n\n"
                    + "Comments: \($0["comments"])\n\n"
                    + "commentCountMap: \($0["commentCountMap"])"
                }
                .store(in: &bindings)

            self.submitButton
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
                    
                    self.vm.saveComment()
                    self.submitButton.isEnabled = false
                    self.submitButton.backgroundColor = .systemGray
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
            self.label,
            self.textField,
            self.submitButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.label.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.label.trailingAnchor, multiplier: 2),
            
            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.label.bottomAnchor, multiplier: 2),
            self.textField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.textField.trailingAnchor, multiplier: 2),
            self.textField.heightAnchor.constraint(equalToConstant: 50),
            
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.textField.bottomAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 2),
            self.submitButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.submitButton.trailingAnchor, multiplier: 5)
        ])
        
        self.submitButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
