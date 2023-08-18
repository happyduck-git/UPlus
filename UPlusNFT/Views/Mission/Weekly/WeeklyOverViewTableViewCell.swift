//
//  WeeklyOverViewTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

final class WeeklyOverViewTableViewCell: UITableViewCell {
    
    private let title: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizLevel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray06
        label.text = MissionConstants.missionLevel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
