//
//  MyTabBarControllerViewController.swift
//  MyLocations
//
//  Created by 123 on 25.03.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class MyTabBarControllerViewController: UITabBarController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childViewControllerForStatusBarStyle: UIViewController? {
        // tab bar controller will look at its own preferredStatusBarStyle property
        // instead of those from the other view controllers
        return nil
    }



}
