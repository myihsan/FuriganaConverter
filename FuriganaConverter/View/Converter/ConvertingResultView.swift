//
//  ConvertingResultView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class ConvertingResultView: NiblessView {

    let resultTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = L10n.convertingResult
        textView.isEditable = false
        return textView
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        constructHierarchy()
        activateConstraints()
    }

    private func constructHierarchy() {
        addSubview(resultTextView)
    }

    private func activateConstraints() {
        resultTextView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
