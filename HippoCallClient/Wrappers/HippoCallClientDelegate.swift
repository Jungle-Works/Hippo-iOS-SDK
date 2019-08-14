//
//  HippoCallClientDelegate.swift
//  HippoCallClient
//
//  Created by Vishal on 14/11/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import Foundation


public protocol HippoCallClientDelegate: class {
    func loadCallPresenterView(request: CallPresenterRequest) -> CallPresenter?
}
