//
//  MockCoreDataStack.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

@testable import FuriganaConverter
import CoreData

class MockCoreDataStack: CoreDataStack {

    override init() {
        super.init()
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: "FuriganaConverter")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        persistentContainer = container
    }
}
