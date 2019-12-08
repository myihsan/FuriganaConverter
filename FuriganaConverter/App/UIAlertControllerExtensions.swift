//
//  UIAlertControllerExtensions.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

extension UIAlertController {

    func addOKAction() {
        let action = UIAlertAction(title: L10n.ok, style: .default)
        addAction(action)
    }

    func addCancelAction() {
        let action = UIAlertAction(title: L10n.cancel, style: .cancel)
        addAction(action)
    }

    func addLaterAction() {
        let action = UIAlertAction(title: L10n.later, style: .cancel)
        addAction(action)
    }
}
