//
//  HelperLocationManager.swift
//  Relly
//
//  Created by Anish on 5/20/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI

class HelperLocationManager: NSObject {
    
    fileprivate  lazy var locationManager = CLLocationManager()
    static let sharedInstance = HelperLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
}

extension HelperLocationManager: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case CLAuthorizationStatus.notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            
        case CLAuthorizationStatus.restricted:
            
            print("Restricted Access to location")
            
        case CLAuthorizationStatus.denied:
            
            print("User denied access to location")
            
        case CLAuthorizationStatus.authorizedWhenInUse:
            
            if #available(iOS 9.0, *) {
                
                locationManager.requestLocation()
                
            } else {
                
                locationManager.startUpdatingLocation()
            }
            
        default:
            
            print("default authorization")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue = locations.last
        print("Location coordinate is \(locValue?.coordinate.latitude),\(locValue?.coordinate.latitude)")
        let nc = NotificationCenter.default
        nc.post(name:.sendLocation,
                object: nil,
                userInfo: ["location":locValue])
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
}
