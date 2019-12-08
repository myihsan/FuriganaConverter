//
//  HistoryCell.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    private let historyIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = .systemGray2
        return imageView
    }()
    private let originalStringLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private let convertedStringLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        constructHierarchy()
        activateConstraints()
    }

    private func constructHierarchy() {
        addSubview(historyIconView)
        labelsStackView.addArrangedSubview(originalStringLabel)
        labelsStackView.addArrangedSubview(convertedStringLabel)
        addSubview(labelsStackView)
    }

    private func activateConstraints() {
        activateHistoryIconViewConstraints()
        activateLabelsStackViewConstraints()
    }

    private func activateHistoryIconViewConstraints() {
        historyIconView.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(16)
        }
    }

    private func activateLabelsStackViewConstraints() {
        labelsStackView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(historyIconView.snp.trailing).offset(10)
            make.trailing.equalTo(self).offset(-16)
        }
    }

    func setHistory(_ history: History) {
        originalStringLabel.text = history.originalString
        convertedStringLabel.text = history.convertedString
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
