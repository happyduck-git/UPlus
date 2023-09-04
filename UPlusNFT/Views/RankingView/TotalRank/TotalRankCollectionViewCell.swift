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
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        
        table.register(Top3RankerTableViewCell.self,
                       forCellReuseIdentifier: Top3RankerTableViewCell.identifier)
        
        table.register(NoRankTableViewCell.self,
                       forCellReuseIdentifier: NoRankTableViewCell.identifier)
        
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: UITableViewCell.identifier)
        
        table.register(TotalRankTableViewCell.self,
                       forCellReuseIdentifier: TotalRankTableViewCell.identifier)
        
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
        self.bind(with: vm)
    }
}

// MARK: - Bind with View Model
extension TotalRankCollectionViewCell {
    private func bind(with vm: RankingViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        /*
        vm.$totalRankerList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.rankTableView.reloadData()
                self.spinner.stopAnimating()
                
            }
            .store(in: &bindings)
        */
        
        vm.$top3RankUserList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.rankTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            .store(in: &bindings)
        
        vm.$exceptTop3RankerList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.rankTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                self.spinner.stopAnimating()
                
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let vm = self.vm else { return 0 }
        
        guard let vm = self.vm else { return 0 }
        
        if vm.totalRankerList.isEmpty {
            return 1
        } else {
            return vm.totalRankSections.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = self.vm else { return 0 }
        
        if vm.totalRankerList.isEmpty {
            return 1
        } else {
            switch section {
            case 0:
                return 1
            default:
                guard let vm = self.vm else { return 0 }
                return vm.exceptTop3RankerList.count
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.vm else { return UITableViewCell() }
        if vm.totalRankerList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoRankTableViewCell.identifier, for: indexPath) as? NoRankTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
            
        } else {
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Top3RankerTableViewCell.identifier) as? Top3RankerTableViewCell,
                      let top3Users = self.vm?.top3RankUserList,
                      let top3UserNfts = self.vm?.top3UserNfts
                else {
                    return UITableViewCell()
                }
                
                cell.configure(top3Users: top3Users, doc: top3UserNfts)
                return cell
                
            default:
                let cellVM = vm.exceptTop3RankerList[indexPath.row]
                let topNft = vm.topNfts[cellVM.userIndex]
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalRankTableViewCell.identifier, for: indexPath) as? TotalRankTableViewCell else {
                    return UITableViewCell()
                }
                cell.resetCell()
                cell.configure(with: cellVM, doc: topNft, at: indexPath.row + 3)
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vm = self.vm else { return 0.0 }
        
        if vm.totalRankerList.isEmpty {
            return self.contentView.frame.height
        } else {
            if indexPath.section == 0 {
                return 356
            } else {
                return 60
            }
        }
    }
    
}

//MARK: - Footer
extension TotalRankCollectionViewCell {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let vm = self.vm else { return nil }
        
        if vm.totalRankerList.isEmpty {
            return nil
        } else {
            if section == 1 {
                let footer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.rankTableView.frame.width, height: 50.0))
                footer.backgroundColor = .white
                return footer
            } else {
                return nil
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let vm = self.vm else { return 0 }
        
        if vm.totalRankerList.isEmpty {
            return 0
        } else {
            if section == 1 {
                return 100
            } else {
                return 0
            }
        }
        
    }
    
}
