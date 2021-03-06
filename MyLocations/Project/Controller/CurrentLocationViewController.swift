//
//  FirstViewController.swift
//  MyLocations
//
//  Created by 123 on 15.11.17.
//  Copyright © 2017 123. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // for - location
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    // for reverse-geocoding
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    // core data
    var managedObjectContext: NSManagedObjectContext!
    
    // logo
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    
    // 0 means no sound has been loaded yet
    var soundID: SystemSoundID = 0
    
    //MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // чтобы показывать или нет labels после загрузки вызовем здесь тоже
        updateLabels()
        configureGetButton()
        loadSoundEffect("Sound.caf")
    }
    
    
    //MARK: - Actions
    @IBAction func getLocation() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if logoVisible {
            hideLogoView()
        }
        
        if authStatus == .notDetermined {
            // запрашиваем авторизацию
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // если запретили
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print(" *** locationManager didFailWithError \(error)")
        
        // You do need to cast to NSError first. This is the subclass of Error
        // that actually contains the code property
        // to convert these names from enum back to an integer value you ask for the rawValue
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            // simply keep trying until you do find a location or
            // receive a more serious error
            return
        }
        
        // In the case of such a more serious error, you store the error
        // object into a new instance variable
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }

    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        // Core Location starts out with a fairly inaccurate locations
        // therefor we chose last one
        
        let newLocation = locations.last!
        print(" *** locationManager didUpdateLocations",
              String(format: "%@", newLocation))
        
        /// проверим accuracy, если нормальная то остановим
        // ignore these cached locations if they are too old
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // sometimes locations may have a horizontalAccuracy that is less than 0,
        // in which case these measurements are invalid and you should ignore them
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // We can use this distance to measure if our location updates are still improving
        /// greatestFiniteMagnitude -> maximum Double value
        // This little trick gives it a gigantic distance if this is the very first reading
        // чтобы потом проверить если < 1 (метра)
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            // взяли дистанцию между 2-мя location
            distance = newLocation.distance(from: location)
        }
        
        // if this is the very first location reading (location is nil) or
        // the new location is more accurate than the previous reading, you continue
        // horizontalAccuracy - this is in metres
        
        // if location == nil, won’t the force unwrapping fail
        // Not in this case, because it is never performed
        
        if location == nil ||
            location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            // clear out any previous error if there was one
            lastLocationError = nil
            
            // stores the new CLLocation object into the location variable
            location = newLocation
            
            updateLabels()
            
            // Wi-Fi might not be able to give you accuracy up to ten meters
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
                
                // if we found very good newLocation
                if distance > 0 {
                    // Simply by setting performingReverseGeocoding to false,
                    // you always force the geocoding to be done for this final coordinate
                    performingReverseGeocoding = false
                }
            }
            
            // The app should only perform a single reverse geocoding request at a time,
            // so first you check whether it is not busy yet by looking
            // at the performingReverseGeocoding variable
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation,
                                                completionHandler: { [unowned self]
                    placemarks, error in
                    
                    print("*** Found placemarks: \(String(describing: placemarks))")
                    print("*** Found error: \(String(describing: error))")
                    
                    self.lastGeocodingError = error
                    if error == nil, let pArr = placemarks, !pArr.isEmpty {
                        
                        if self.placemark == nil {
                            print("FIRST TIME!")
                            self.playSoundEffect()
                        }
                        
                        self.placemark = pArr.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
            
        } else if distance < 1 {
            // если новая коорд не лучше прежней, а дистанция между ними 1 метр
            // и прошло > 10 секунд, то остановим manager
            
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force done!")
                
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    
    //MARK: - Helpers
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }

    
    func configureGetButton() {
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Start / Stop udating
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            // "time-out" if it takes too long finding a location
            timer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(didTimeOut),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    // If after one minute there still is no valid location,
    // you stop the location manager, create your own error code, and update the screen
    
    @objc fileprivate func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            // By creating your own NSError object and putting it into
            // the lastLocationError instance variable,
            // you don’t have to change any of the logic in updateLabels()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1,
                                        userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    // You put all this logic into a single method because that
    // makes it easy to change the screen when something has changed
    
    func updateLabels() {
        // если получили location
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            // если не получили location
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                // the error domain kCLErrorDomain, which means Core Location errors
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
                
                // Even if there was no error it might still be impossible
                // to get location coordinates if the user disabled
                // Location Services completely on device
                
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            }
            else {
                statusMessage = ""
                showLogoView()
            }
            messageLabel.text = statusMessage
        }
    }
    
    // MARK: - Logo View
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        
        // containerView is placed outside the screen and moved to the center
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        // logo imageview slides out of the screen
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        // at the same time rotates around its center, giving impression that it’s rolling away
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    // MARK: - Alert
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            // coordinate is value type -> copied to
            // Each view controller now has its own unique copy of those GPS coordinates
            controller.coordinate = location!.coordinate
            
            // Both view controllers point to the same CLPlacemark object (or nil if placemark has no value)
            // If you want an object with a reference type to be copied when
            // it is assigned to another variable, you can declare it as @NSCopying
            // @NSCopying var pl: CLPlacemark?
            controller.placemark = placemark
            
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    deinit {
        print(" *** CurrentLocationViewController deinited")
    }
    
    // MARK: - Sound Effect
    func loadSoundEffect(_ name: String) {
        // method loads the sound file and puts it into a new sound object
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }

}


















