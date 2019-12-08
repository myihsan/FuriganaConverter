//
//  FuriganaConverterDependencyContainer.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import CoreData

class AppDependencyContainer {

    private let coreDataStack = CoreDataStack()
    private lazy var historyFetchedResultsController = createFetchedResultsController(coreDataStack: coreDataStack)

    func makeConvertorViewController() -> ConverterViewController {
        let historyView = ConverterHistoryView(historyFetchedResultsController: historyFetchedResultsController)
        let userInterface = ConverterRootView(historyView: historyView)
        let remoteAPI = GooFuriganaConverterRemoteAPI(session: .shared)
        let historyHolder = CoreDataHistoryHolder(fetchedResultsController: historyFetchedResultsController)
        let viewController = ConverterViewController(
            userInterface: userInterface,
            remoteAPI: remoteAPI,
            coreDataStack: coreDataStack,
            historyHolder: historyHolder,
            makeSettingViewController: makeSettingViewController
        )
        historyView.eventResponder = viewController
        userInterface.eventResponder = viewController
        return viewController
    }

    func makeSettingViewController() -> UIViewController {
        let userInterface = SettingRootView()
        let settingViewController = SettingViewController(
            userInterface: userInterface,
            coreDataStack: coreDataStack
        )
        userInterface.eventResponder = settingViewController
        let navigationController = UINavigationController(rootViewController: settingViewController)
        return navigationController
    }

    private func createFetchedResultsController(coreDataStack: CoreDataStack) -> NSFetchedResultsController<History> {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(History.timestamp), ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "History"
        )

        return fetchedResultsController
    }
}
