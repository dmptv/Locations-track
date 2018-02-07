//
//  Functions.swift
//  MyLocations
//
//  Created by 123 on 05.12.17.
//  Copyright © 2017 123. All rights reserved.
//

import Foundation
import Dispatch

//  This is a free function, not a method inside an object,
// and as a result it can be used from anywhere in your code
func afterDelay(_ seconds: Double,
                closure: @escaping () -> ()) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
                                  execute: closure)
}


// global constant, applicationDocumentsDirectory,
// containing the path to the app’s Documents directory.
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                         in: FileManager.SearchPathDomainMask.userDomainMask)
    return paths[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification,
                                    object: nil)
}

















