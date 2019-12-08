//
//  SettingViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import AcknowList
import CoreData

class SettingViewController: NiblessViewController {

    private let userInterface: SettingUserInterfaceView
    private let coreDataStack: CoreDataStack

    init(
        userInterface: SettingUserInterfaceView,
        coreDataStack: CoreDataStack
    ) {
        self.userInterface = userInterface
        self.coreDataStack = coreDataStack
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

        disableClearHitoryCellIfNeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userInterface.deselectCells()
    }

    private func disableClearHitoryCellIfNeed() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = History.fetchRequest()
        do {
            let count = try coreDataStack.managedContext.count(for: fetchRequest)
            if count == 0 {
                userInterface.disableClearHistoryCell()
            }
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    @objc
    private func done() {
        dismiss(animated: true)
    }
}

extension SettingViewController: SettingEventResponder {

    func clearHistory() {
        userInterface.deselectCells()
        let alertController = UIAlertController()
        alertController.addCancelAction()
        let clearAction = UIAlertAction(title: L10n.clearHistory, style: .destructive) { _ in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = History.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.coreDataStack.managedContext.execute(deleteRequest)
                NotificationCenter.default.post(name: .didClearHistory, object: self)
                self.userInterface.disableClearHistoryCell()
            } catch {
                self.presentClearFailedAlert()
            }
        }
        alertController.addAction(clearAction)
        present(alertController, animated: true)
    }

    private func presentClearFailedAlert() {
        let alertController = UIAlertController(title: L10n.clearFailed, message: nil, preferredStyle: .alert)
        alertController.addOKAction()
        present(alertController, animated: true)
    }

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
