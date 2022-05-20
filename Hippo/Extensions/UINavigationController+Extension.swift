//
//  UINavigationController+Extension.swift
//  Hippo
//
//  Created by soc-admin on 20/05/22.
//

import Foundation

extension UINavigationController {
    func isControllerExist(controller: AnyClass) -> UIViewController? {
        for existingController in self.viewControllers {
            if existingController.isKind(of: controller) {
                return existingController
            }
        }
        return nil
    }
}
