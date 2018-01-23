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
        debugPrint("Location Right")
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        } else {
            debugPrint("Location Can not be access")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let newLocation = locations.first {
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                
                if let error = error {
                    debugPrint("reverse geodcode fail: \(error.localizedDescription)")
                }
                
                if let pm = placemarks {
                    if pm.count > 0 {
                        
                        let placemark = pm.first
                        
                        self.address = placemark?.locality
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DiaryLocationUpdated"), object: self.address)
                    }
                }
                
            })
        }

    }
}

