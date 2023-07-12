//
//  PostViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit
import FirebaseAuth
import Combine

final class PostViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: PostViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Element
    private let postsTableView: UITableView = {
        let table = UITableView()
        table.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Init
    init(vm: PostViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension PostViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "메인화면"
        view.backgroundColor = .tertiarySystemBackground
        vm.fetchAllInitialPosts()
        
        setUI()
        setLayout()
        setDelegate()
        bind()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        let writePostBarButtomItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(showWritePostVC))
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logOutDidTap))
        navigationItem.rightBarButtonItems = [writePostBarButtomItem, logoutBarButtonItem]

    }
}

// MARK: - Set UI & Layout & Delegate
extension PostViewController {
    private func setUI() {
        view.addSubviews(postsTableView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.postsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.postsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.postsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.postsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
    }
}

// MARK: - Bind ViewModel
extension PostViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            
            vm.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.postsTableView.reloadData()
            }
            .store(in: &bindings)
            
            vm.$didLoadAdditionalPosts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.postsTableView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Private Functions
extension PostViewController {
    @objc
    private func showWritePostVC() {
        let vm = WritePostViewViewModel()
        let vc = WritePostViewController(type: .newPost, vm: vm)
        
        navigationController?.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }
    
    @objc
    private func logOutDidTap() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }
        catch {
            print("Error logout user \(error.localizedDescription)")
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        cell.resetCell()
        let vm = vm.cellForRow(at: indexPath.row)
        cell.delegate = self
        cell.configure(with: vm)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.modalPresentationStyle = .fullScreen
        
        let vm = vm.postDetailViewModel(at: indexPath.row)
        let campaignCellVM = self.vm.campaignCellViewModel(postId: vm.postId)
        
        switch vm.postType {
        case .article:
            let campaignPostVM = CampaignPostViewViewModel(
                postId: vm.postId,
                postType: vm.postType,
                post: vm,
                campaign: nil
            )
            let vc = CampaignPostViewController(
                postType: vm.postType,
                campaignPostVM: campaignPostVM
            )

            vc.delegate = self
            vc.indexPath = indexPath
            self.show(vc, sender: self)
        default:
            let campaignPostVM = CampaignPostViewViewModel(
                postId: vm.postId,
                postType: vm.postType,
                post: vm,
                campaign: campaignCellVM
            )
            let vc = CampaignPostViewController(
                postType: vm.postType,
                campaignPostVM: campaignPostVM
            )
            vc.delegate = self
            vc.indexPath = indexPath
            self.show(vc, sender: self)
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension PostViewController: PostTableViewCellProtocol {
    func likeButtonDidTap(vm: PostTableViewCellModel) {
        Task {
            do {
                try await self.vm.updatePostLike(postId: vm.postId, isLiked: vm.isLiked)
            }
            catch {
                print("Failed to update post like -- \(error.localizedDescription)")
            }
        }
    }
}

extension PostViewController: CampaignPostViewControllerDelegate {
    func likebuttonDidTap(at indexPath: IndexPath, isLiked: Bool) {
        let vm = self.vm.tableDataSource[indexPath.row]
        vm.isLiked = isLiked
    }
}

// MARK: - Scrolling Pagination
extension PostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height

        if offset >= (totalContentHeight - totalScrollViewFixedHeight) &&
            vm.queryDocumentSnapshot != nil &&
            !vm.isLoading
        {
            vm.fetchAdditionalPosts()
        }
    }
}
