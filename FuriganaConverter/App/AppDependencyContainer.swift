//
//  FuriganaConverterDependencyContainer.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import CoreData

class AppDependencyContainer {

    func makeConvertorViewController() -> ConvertorViewController {
        let coreDataStack = CoreDataStack()
        let historyFetchedResultsController = createFetchedResultsController(coreDataStack: coreDataStack)
        let historyView = ConverterHistoryView(historyFetchedResultsController: historyFetchedResultsController)
        let userInterface = ConverterRootView(historyView: historyView)
        let remoteAPI = GooFuriganaConverterRemoteAPI(session: .shared)
        let viewController = ConvertorViewController(
            userInterface: userInterface,
            remoteAPI: remoteAPI,
            coreDataStack: coreDataStack
        )
        userInterface.eventResponder = viewController
        return viewController
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
