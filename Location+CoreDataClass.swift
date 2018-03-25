//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by 123 on 06.12.17.
//  Copyright © 2017 123. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit


@objc(Location)
public class Location: NSManagedObject {

    public var hasPhoto: Bool {
        return photoID != nil
    }
    
    public var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    public var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    public class func nextPhotoID() -> Int {
        // uses merely for calculating id
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    public func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
}

extension Location: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
}












