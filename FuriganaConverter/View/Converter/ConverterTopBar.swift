//
//  ConverterTopBar.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class ConverterTopBar: UINavigationBar {

    override var barPosition: UIBarPosition { .topAttached }

    let typeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [L10n.hinagara, L10n.katakana])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    private let navigationItem = UINavigationItem()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        constructHierarchy()
        activateConstraints()
    }

    func constructHierarchy() {
        // Add directly to controller the size with constraints
        addSubview(typeSegmentedControl)
    }

    func activateConstraints() {
        typeSegmentedControl.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            // Reasonable offset value to avoid the left and right button from Apple Design Resources
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading).offset(64) // 10 + 44 + 10
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-64) // 10 + 44 + 10
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
