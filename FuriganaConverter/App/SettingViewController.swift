//
//  SettingViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class SettingViewController: NiblessViewController {

    override func loadView() {
        view = SettingRootView()
    }

    override func viewDidLoad() {
        title = L10n.settings
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = doneButtonItem
    }

    @objc
    private func done() {
        dismiss(animated: true)
    }
}
