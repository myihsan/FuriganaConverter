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

    weak var eventResponder: ConverterHistoryEventResponder?

    init(historyFetchedResultsController: NSFetchedResultsController<History>) {
        self.historyFetchedResultsController = historyFetchedResultsController
        super.init(frame: .zero)

        historyFetchedResultsController.delegate = self
        fetchHistories()
        NotificationCenter.default
            .addObserver(self, selector: #selector(didClearHistory), name: .didClearHistory, object: nil)

        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    private func fetchHistories() {
        do {
            try historyFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    @objc
    private func didClearHistory() {
        fetchHistories()
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ConverterHistoryView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = historyFetchedResultsController.object(at: indexPath)
        eventResponder?.didSelect(history)
        tableView.deselectRow(at: indexPath, animated: true)
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

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let history = historyFetchedResultsController.object(at: indexPath)
            eventResponder?.delete(history)
        }
    }
}

extension ConverterHistoryView: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)!
            setupCell(cell, indexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
