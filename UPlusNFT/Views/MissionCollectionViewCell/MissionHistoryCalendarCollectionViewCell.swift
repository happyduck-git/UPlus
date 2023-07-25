//
//  MissionHistoryCalendarCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/25.
//

import UIKit
import FSCalendar

final class MissionHistoryCalendarCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let calendar: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.backgroundColor = .white
        calendar.clipsToBounds = true
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerDateFormat = "MM"
        calendar.appearance.weekdayTextColor = .systemGray
        calendar.firstWeekday = 1
        calendar.locale = Locale.init(identifier: "en")
        
        let numOfDays = calendar.calendarWeekdayView.weekdayLabels.count
        calendar.calendarWeekdayView.weekdayLabels[numOfDays - 2].textColor = UPlusColor.pointCirclePink
        calendar.calendarWeekdayView.weekdayLabels[numOfDays - 1].textColor = UPlusColor.pointCirclePink
        calendar.placeholderType = .none
        calendar.appearance.todayColor = UPlusColor.pointCirclePink
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemGray6
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MissionHistoryCalendarCollectionViewCell {
    private func setUI() {
        self.contentView.addSubview(calendar)
        self.calendar.layer.cornerRadius = 10
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.calendar.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.calendar.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.calendar.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.calendar.bottomAnchor, multiplier: 1)
        ])
        
        
    }
}

extension MissionHistoryCalendarCollectionViewCell: FSCalendarDelegateAppearance {
    
}
