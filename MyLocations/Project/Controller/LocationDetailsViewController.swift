//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by 123 on 18.11.17.
//  Copyright © 2017 123. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// private global constant
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print(" *** formatter lazy init")
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0,
                                            longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    
    // core data
    var managedObjectContext: NSManagedObjectContext!
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc fileprivate func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        
        // where the tap happened
        let point = gestureRecognizer.location(in: tableView)
        
        // index-path is currently displayed at that position
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil &&
            indexPath!.section == 0 &&
            indexPath!.row == 0 {
            
            // you don’t want to hide the keyboard if the user
            // tapped in the row with the text view!
            
            return
        }

        descriptionTextView.resignFirstResponder()
    }
    
    fileprivate func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " " }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    fileprivate func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    // MARK: - Actions
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view,
                                  animated: true)
        hudView.text = "Tagged"
        
        let location = Location(context: managedObjectContext)
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
           fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(
                width: view.bounds.width - 115,
                height: 10000)
            
            // UILabel will word-wrap the text to fit the requested width
            // because set the text on the label in viewDidLoad()
            
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width -
                addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44 }
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            // limits taps
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
}






















