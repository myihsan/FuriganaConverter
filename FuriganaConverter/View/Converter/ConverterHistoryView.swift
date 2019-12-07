//
//  ConverterHistoryView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import CoreData

class ConverterHistoryView: NiblessView {

    private static let cellReuseIdentifier = "Cell"

    private let historyFetchedResultsController: NSFetchedResultsController<History>
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 60
        tableView.register(HistoryCell.self, forCellReuseIdentifier: ConverterHistoryView.cellReuseIdentifier)
        return tableView
    }()

    init(historyFetchedResultsController: NSFetchedResultsController<History>) {
        self.historyFetchedResultsController = historyFetchedResultsController
        super.init(frame: .zero)

        historyFetchedResultsController.delegate = self
        do {
            try historyFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

        tableView.dataSource = self
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

extension ConverterHistoryView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyFetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)
        setupCell(cell, indexPath: indexPath)
        return cell
    }

    func setupCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let cell = cell as? HistoryCell else {
            return
        }
        let history = historyFetchedResultsController.object(at: indexPath)
        cell.setHistory(history)
    }
}

extension ConverterHistoryView: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
