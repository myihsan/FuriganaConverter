//
//  SettingViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import AcknowList

class SettingViewController: NiblessViewController {

    private let userInterface: SettingUserInterfaceView

    init(userInterface: SettingUserInterfaceView) {
        self.userInterface = userInterface
        super.init()
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        navigationController?.delegate = self
        title = L10n.settings
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = doneButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userInterface.deselectCells()
    }

    @objc
    private func done() {
        dismiss(animated: true)
    }
}

extension SettingViewController: SettingEventResponder {

    func showAcknowledgements() {
        let viewController = AcknowListViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // Add done button for AcknowListViewController
        if viewController.navigationItem.rightBarButtonItem == nil {
            let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            viewController.navigationItem.rightBarButtonItem = doneButtonItem
        }
    }
}
