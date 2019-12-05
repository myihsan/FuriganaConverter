//
//  ConverterRootView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import SnapKit

class ConverterRootView: NiblessView {

    private let navigationBar = UINavigationBar()
    private let keyboardButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "keyboard")!,
            style: .plain,
            target: nil,
            action: nil
        )
        return buttonItem
    }()
    private let convertButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: "Convert",
            style: .done,
            target: nil,
            action: nil
        )
        buttonItem.isEnabled = false
        return buttonItem
    }()
    private let toolbar = UIToolbar()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        constructHierarchy()
        activateConstraints()
    }

    private func constructHierarchy() {
        addSubview(navigationBar)
        addSubview(toolbar)

        let flexibleSpace =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [keyboardButtonItem, flexibleSpace, convertButtonItem]
    }

    private func activateConstraints() {
        activeNavigationBarConstraints()
        activeToolbarConstraints()
    }

    private func activeNavigationBarConstraints() {
        navigationBar.delegate = self
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }

    private func activeToolbarConstraints() {
        toolbar.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension ConverterRootView: UINavigationBarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ConverterRootViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        ConverterRootView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ConverterRootView_Previews: PreviewProvider {

    static var previews: some View {
        ConverterRootViewRepresentable()
    }
}
#endif
