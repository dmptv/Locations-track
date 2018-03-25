//
//  String+AddText.swift .swift
//  MyLocations
//
//  Created by 123 on 25.03.2018.
//  Copyright © 2018 123. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text }
    }
}
