//
//  FuguConfig.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/16/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//


@available(*, deprecated, renamed: "HippoConfig", message: "This class will no longer be available, To Continue migrate to HippoConfig")
public class FuguConfig {
    public static var shared: HippoConfig = {
        return HippoConfig.shared
    }()
}
