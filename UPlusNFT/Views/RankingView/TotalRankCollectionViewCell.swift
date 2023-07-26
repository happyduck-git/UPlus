//
//  TotalRankCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import UIKit
import Combine

final class TotalRankCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: RankingViewViewModel?

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let rankTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        // TODO: Register Custom Cell
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)

        return table
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure with View Model
extension TotalRankCollectionViewCell {
    func configure(with vm: RankingViewViewModel) {
        self.vm = vm
        vm.getTotalRanking()
        self.bind(with: vm)
    }
}

// MARK: - Bind with View Model
extension TotalRankCollectionViewCell {
    private func bind(with vm: RankingViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$totalRankUserList
            .receive(on: DispatchQueue.main)
            .sink { [weak self]in
                guard let `self` = self else { return }
                if !$0.isEmpty {
                    self.rankTableView.reloadData()
                    self.spinner.stopAnimating()
                }
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension TotalRankCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.rankTableView,
                                     self.spinner)
    }
    
    private func setLayout() {
        self.rankTableView.frame = self.contentView.bounds
        self.spinner.frame = self.contentView.bounds
    }
    
    private func setDelegate() {
        self.rankTableView.delegate = self
        self.rankTableView.dataSource = self
    }
}

// MARK: - TableViw Delegate & DataSource
extension TotalRankCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = self.vm else { return 0 }
        return vm.totalRankUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.vm else { fatalError() }
        let cellVM = vm.totalRankUserList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = "\(cellVM.userNickname) -- Point: \(cellVM.userTotalPoint ?? 0)"
        cell.contentConfiguration = config
        return cell
    }
}
