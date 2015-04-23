//
//  DiaryLocationHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/3/7.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import CoreLocation

class DiaryLocationHelper: NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var address:String?
    var geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.requestWhenInUseAuthorization()
        println("Location Right")
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
            
            if (error != nil) {println("reverse geodcode fail: \(error.localizedDescription)")}
            
            if let pm = placemarks as? [CLPlacemark] {
                if pm.count > 0 {
                    
                    var placemark = pm.first
                    
                    self.address = placemark?.locality
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("DiaryLocationUpdated", object: self.address)
                }
            }

        })
    }
}

