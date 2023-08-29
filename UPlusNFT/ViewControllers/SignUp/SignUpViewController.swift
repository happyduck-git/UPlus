//
//  SignUpViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import Combine

protocol SignUpViewControllerDelegate: AnyObject {
    func signupDidComplete()
}

final class SignUpViewController: UIViewController {
    
    //MARK: - Dependency
    private var signupVM: SignUpViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Delegate
    weak var delegate: SignUpViewControllerDelegate?
    
    // MARK: - UI Elements
    private let emailTitleLabel: UILabel = {
        let label = UILabel()

        let font: UIFont = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        let attributedString = NSMutableAttributedString(string: SignUpConstants.emailLabel, attributes: [
            .foregroundColor: UIColor.black,
            .font: font
        ])
        let star = NSAttributedString(string: SignUpConstants.star, attributes: [
            .foregroundColor: UPlusColor.mint04,
            .font: font
        ])
        
        attributedString.append(star)
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.uplusEmailSuffix
        label.textColor = UPlusColor.gray07
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let txtField = UITextField()
        txtField.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let emailValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pwLabel: UILabel = {
        let label = UILabel()
        let font: UIFont = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        let attributedString = NSMutableAttributedString(string: SignUpConstants.passwordLabel, attributes: [
            .foregroundColor: UIColor.black,
            .font: font
        ])
        let star = NSAttributedString(string: SignUpConstants.star, attributes: [
            .foregroundColor: UPlusColor.mint04,
            .font: font
        ])
        
        attributedString.append(star)
        label.attributedText = attributedString

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pwTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isSecureTextEntry = true
        txtField.textContentType = .newPassword
//        txtField.text = "Pass1234" // DEBUG
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let pwValidationStack: UIStackView = {
        let stack = UIStackView()
        stack.isHidden = true
        stack.axis = .horizontal
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let pwValidationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.infoRed)
        return imageView
    }()
    
    private let pwValidationText: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.passwordValidation
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.orange01
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pwCheckLabel: UILabel = {
        let label = UILabel()
        let font: UIFont = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        let attributedString = NSMutableAttributedString(string: SignUpConstants.passwordCheckLabel, attributes: [
            .foregroundColor: UIColor.black,
            .font: font
        ])
        let star = NSAttributedString(string: SignUpConstants.star, attributes: [
            .foregroundColor: UPlusColor.mint04,
            .font: font
        ])
        
        attributedString.append(star)
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pwCheckTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.textContentType = .newPassword
        txtField.isSecureTextEntry = true
        txtField.isUserInteractionEnabled = false
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let pwCheckValidationStack: UIStackView = {
        let stack = UIStackView()
        stack.isHidden = true
        stack.axis = .horizontal
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let pwCheckValidationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.infoRed)
        return imageView
    }()
    
    private let pwCheckValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    private let personalInfoStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let acceptInfoLabel: UILabel = {
        let label = UILabel()
        
        let font: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        let attributedString = NSMutableAttributedString(string: SignUpConstants.personalInfo, attributes: [
            .foregroundColor: UPlusColor.gray06,
            .font: font
        ])
        let suffix = NSAttributedString(string: SignUpConstants.required, attributes: [
            .foregroundColor: UPlusColor.mint04,
            .font: font
        ])
        
        attributedString.append(suffix)
        label.attributedText = attributedString
        
        return label
    }()
    
    private let showAllButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.showAll, for: .normal)
        button.setTitleColor(UPlusColor.gray06, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        button.setUnderline(1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.register, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = SignUpConstants.signUp
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setNavigationItem()
        
        self.bind()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - Init
    init(vm: SignUpViewViewModel) {
        self.signupVM = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        self.view.addSubviews(
            self.emailTitleLabel,
            self.emailTextField,
            self.emailValidationText,

            self.pwLabel,
            self.pwTextField,
            self.pwValidationStack,
            
            self.pwCheckLabel,
            self.pwCheckTextField,
            self.pwCheckValidationStack,
            
            self.personalInfoStack,
            self.showAllButton,
            self.registerButton
        )
        
        self.personalInfoStack.addArrangedSubviews(self.checkButton,
                                                   self.acceptInfoLabel)
        
        self.pwValidationStack.addArrangedSubviews(self.pwValidationImage,
                                                   self.pwValidationText)
        
        self.pwCheckValidationStack.addArrangedSubviews(self.pwCheckValidationImage,
                                                        self.pwCheckValidationText)
        
        
        
        // Adding a PlaceHolderView
        placeHolderView.addSubview(placeHolderLabel)
        self.emailTextField.rightView = placeHolderView
        self.emailTextField.rightViewMode = .always
    }
     
    private func setLayout() {
        NSLayoutConstraint.activate([
            emailTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            emailTitleLabel.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            
            emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailTitleLabel.bottomAnchor, multiplier: 1),
            emailTextField.heightAnchor.constraint(equalToConstant: LoginConstants.textFieldHeight),
            emailTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3),
            
            emailValidationText.topAnchor.constraint(equalToSystemSpacingBelow: emailTextField.bottomAnchor, multiplier: 1),
            emailValidationText.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: placeHolderView.topAnchor, multiplier: 1),
            placeHolderLabel.leadingAnchor.constraint(equalTo: placeHolderView.leadingAnchor),
            placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: placeHolderLabel.trailingAnchor, multiplier: 1),
            placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: placeHolderLabel.bottomAnchor, multiplier: 1),
            
            pwLabel.topAnchor.constraint(equalToSystemSpacingBelow: emailValidationText.bottomAnchor, multiplier: 2),
            pwLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            pwTextField.topAnchor.constraint(equalToSystemSpacingBelow: pwLabel.bottomAnchor, multiplier: 1),
            pwTextField.heightAnchor.constraint(equalToConstant: LoginConstants.textFieldHeight),
            pwTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            pwTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            pwValidationStack.topAnchor.constraint(equalToSystemSpacingBelow: pwTextField.bottomAnchor, multiplier: 1),
            pwValidationStack.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            pwCheckLabel.topAnchor.constraint(equalToSystemSpacingBelow: pwValidationStack.bottomAnchor, multiplier: 2),
            pwCheckLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            pwCheckTextField.topAnchor.constraint(equalToSystemSpacingBelow: pwCheckLabel.bottomAnchor, multiplier: 1),
            pwCheckTextField.heightAnchor.constraint(equalToConstant: LoginConstants.textFieldHeight),
            pwCheckTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            pwCheckTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            pwCheckValidationStack.topAnchor.constraint(equalToSystemSpacingBelow: pwCheckTextField.bottomAnchor, multiplier: 1),
            pwCheckValidationStack.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),

            self.personalInfoStack.topAnchor.constraint(equalToSystemSpacingBelow: self.pwCheckValidationStack.bottomAnchor, multiplier: 6),
            self.personalInfoStack.leadingAnchor.constraint(equalTo: pwTextField.leadingAnchor),
            
            self.showAllButton.topAnchor.constraint(equalTo: self.personalInfoStack.topAnchor),
            self.showAllButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.personalInfoStack.trailingAnchor, multiplier: 2),
            self.showAllButton.trailingAnchor.constraint(equalTo: self.pwTextField.trailingAnchor),
            self.showAllButton.bottomAnchor.constraint(equalTo: self.personalInfoStack.bottomAnchor),
            
            registerButton.topAnchor.constraint(equalToSystemSpacingBelow: personalInfoStack.bottomAnchor, multiplier: 5),
            registerButton.heightAnchor.constraint(equalToConstant: LoginConstants.textFieldHeight),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
            
        ])
    }
    
    private func setNavigationItem() {
        self.navigationItem.hidesBackButton = true
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: ImageAsset.xMarkBlack)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                          style: .plain,
                                          target: self,
                                           action: #selector(cancelButtonDidTap))
        
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }

    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.email, on: self.signupVM)
                .store(in: &bindings)
            
            self.pwTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.password, on: self.signupVM)
                .store(in: &bindings)
            
            self.pwCheckTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.passwordCheck, on: self.signupVM)
                .store(in: &bindings)

            self.checkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.signupVM.isPersonalInfoChecked.toggle()
                }
                .store(in: &bindings)
            
            self.showAllButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    // TODO: 전문보기 탭 시 action 설정 필요
                    
                }
                .store(in: &bindings)
            
            self.registerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.registerButtonDidTap()
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            
            self.signupVM.$email
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0.isEmpty {
                        self.emailValidationText.text = ""
                    }
                }
                .store(in: &bindings)

            self.signupVM.isPasswordValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.pwTextField.text ?? ""
                    
                    var isHidden = false
                    var isInteractive = false
                    var bgColor: UIColor?
                    
                    if valid {
                        isHidden = true
                        isInteractive = true
                        bgColor = .white
                    } else if passwordText.isEmpty {
                        isHidden = true
                        isInteractive = false
                        bgColor = .systemGray3
                    } else {
                        isHidden = false
                        isInteractive = false
                        bgColor = .systemGray3
                    }
                    
                    self.pwValidationStack.isHidden = isHidden
                    self.pwCheckTextField.isUserInteractionEnabled = isInteractive
                    self.pwCheckTextField.backgroundColor = bgColor
                }
                .store(in: &bindings)
            
            self.signupVM.isPasswordSame
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.pwCheckTextField.text ?? ""
                    
                    var text = ""
                    var textColor: UIColor?
                    var image: UIImage?
                    
                    if valid {
                        self.pwCheckValidationStack.isHidden = false
                        text = SignUpConstants.passwordMatch
                        textColor = UPlusColor.blue03
                        image = UIImage(named: ImageAsset.infoBlue)
                        
                    } else if passwordText.isEmpty {
                        self.pwCheckValidationStack.isHidden = true
                        
                    } else {
                        self.pwCheckValidationStack.isHidden = false
                        text = SignUpConstants.passwordNotMatch
                        textColor = UPlusColor.orange01
                        image = UIImage(named: ImageAsset.infoRed)
                    }
                    
                    self.pwCheckValidationText.text = text
                    self.pwCheckValidationText.textColor = textColor
                    self.pwCheckValidationImage.image = image
                    
                }
                .store(in: &bindings)
            
            self.signupVM.isAllInfoChecked
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    
                    var interaction: Bool = false
                    var bgColor: UIColor?
                    var textColor: UIColor?
                    
                    if valid {
                        interaction = true
                        bgColor = UPlusColor.mint03
                        textColor = .black
                        
                    } else {
                        interaction = false
                        bgColor = UPlusColor.gray03
                        textColor = .white
                        
                    }
                    
                    self.registerButton.isUserInteractionEnabled = interaction
                    self.registerButton.backgroundColor = bgColor
                    self.registerButton.setTitleColor(textColor, for: .normal)
                    
                }
                .store(in: &bindings)
            
            self.signupVM.isUserCreated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                       print("User created called.")
                        // Request a single NFT to NFT Service.
                        self.signupVM.requestToCreateNewUserNft()
                        
                        let vm = SignUpCompleteViewViewModel()
                        let vc = SignUpCompleteViewController(vm: vm)
                        
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                    
                    } else {
                        self.emailValidationText.textColor = .systemRed
                        self.emailValidationText.text = self.signupVM.errorDescription
                    }
                }
                .store(in: &bindings)
            
            self.signupVM.$isPersonalInfoChecked
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isChecked in
                    guard let `self` = self else { return }
                    
                    var image: UIImage?
                    if isChecked {
                        image = UIImage(named: ImageAsset.checkBoxTicked)
                    } else {
                        image = UIImage(named: ImageAsset.checkBoxEmpty)
                    }
                    
                    self.checkButton.setImage(image, for: .normal)
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

//MARK: - Private
extension SignUpViewController {

    @objc private func registerButtonDidTap() {
        Task {
            await self.signupVM.createNewUser()
            if !self.signupVM.isValidUser {
                self.emailValidationText.text = self.signupVM.errorDescription
            }
        }
    }
    
    @objc private func cancelButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController: SignUpCompleteViewControllerDelegate {
    func welcomeButtonDidTap() {
        self.delegate?.signupDidComplete()
    }
}
