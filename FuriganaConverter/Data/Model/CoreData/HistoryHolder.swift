//
//  HistoryHolder.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import CoreData

protocol HistoryHolder {

    var histories: [History] { get }
}

class CoreDataHistoryHolder: HistoryHolder {

    let fetchedResultsController: NSFetchedResultsController<History>
    var histories: [History] {
        fetchedResultsController.fetchedObjects ?? []
    }

    init(fetchedResultsController: NSFetchedResultsController<History>) {
        self.fetchedResultsController = fetchedResultsController
    }
}
