//
//  SettingRootView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class SettingRootView: NiblessView {

    weak var eventResponder: SettingEventResponder?

    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        navigationItem.title = L10n.settings
        let closeButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem = closeButtonItem
        navigationBar.items = [navigationItem]
        return navigationBar
    }()
    private let autoShowKeyboardSwitch = UISwitch()
    private lazy var autoShowKeyboardCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = L10n.showKeyboardAutomatically
        cell.accessoryView = autoShowKeyboardSwitch
        return cell
    }()
    private lazy var clearHistoryCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.textLabel?.text = L10n.clearHistory
        cell.textLabel?.textColor = tintColor
        return cell
    }()
    private lazy var acknowledgementsCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.textLabel?.text = L10n.acknowledgements
        cell.accessoryType = .disclosureIndicator
        return cell
    }()
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private lazy var cells = [
        IndexPath(row: 0, section: 0): autoShowKeyboardCell,
        IndexPath(row: 0, section: 1): clearHistoryCell,
        IndexPath(row: 0, section: 2): acknowledgementsCell
    ]

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

extension SettingRootView: UINavigationBarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

extension SettingRootView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }
}

extension SettingRootView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath] {
        case clearHistoryCell:
            if clearHistoryCell.textLabel?.isEnabled == false {
                return
            }
            eventResponder?.clearHistory()
        case acknowledgementsCell:
            eventResponder?.showAcknowledgements()
        default:
            break
        }
    }
}

extension SettingRootView: SettingUserInterface {

    func disableClearHistoryCell() {
        clearHistoryCell.selectionStyle = .none
        clearHistoryCell.textLabel?.isEnabled = false
    }

    func deselectCells() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
