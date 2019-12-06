//
//  FuriganaConverterDependencyContainer.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

class AppDependencyContainer {

    func makeConvertorViewController() -> ConvertorViewController {
        let userInterface = ConverterRootView()
        let remoteAPI = GooFuriganaConverterRemoteAPI(session: .shared)
        let viewController = ConvertorViewController(userInterface: userInterface, remoteAPI: remoteAPI)
        userInterface.eventResponder = viewController
        return viewController
    }
}
