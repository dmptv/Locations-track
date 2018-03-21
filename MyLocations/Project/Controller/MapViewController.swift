//
//  MapViewController.swift
//  MyLocations
//
//  Created by 123 on 19.03.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations as [MKAnnotation])
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations as [MKAnnotation])
    }
    
    // By looking at the highest and lowest values for the latitude and longitude of all the
    // Location objects, you can calculate a region and then tell the map view to zoom to that region
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
        
            let center = CLLocationCoordinate2D(latitude:
                topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                                                longitude:
                topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.2
            
            // abs() always makes a number positive (absolute value)
            let span = MKCoordinateSpan(latitudeDelta:
                abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                                        longitudeDelta:
                abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    
    
    // MARK: - Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
    }
   
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 1
        guard annotation is Location else {
            return nil
        }
            // 2
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                // 3
                pinView.isEnabled = true
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
                // 4
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
                pinView.rightCalloutAccessoryView = rightButton
                annotationView = pinView
        }
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            // 5
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }
    
}



















