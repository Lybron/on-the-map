//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Properties
  var locations = StudentInformationStore.shared.students
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerForNotifications()
    setAnnotations()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    unregisterForNotifications()
  }
  
  @objc func setAnnotations() {
    self.mapView.removeAnnotations(self.mapView.annotations)
    
    for annotation in self.mapView.annotations {
      self.mapView.removeAnnotation(annotation)
    }
    
    for location in StudentInformationStore.shared.students {
      
      let latitude = CLLocationDegrees(location.latitude)
      let longitude = CLLocationDegrees(location.longitude)
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      
      let firstName = location.firstName
      let lastName = location.lastName
      let mediaURL = location.mediaURL
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(firstName) \(lastName)"
      annotation.subtitle = mediaURL
      
      self.mapView.addAnnotation(annotation)
    }
        
  }
  
  // MARK: Notifications
  private func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(setAnnotations), name: NSNotification.Name(rawValue: StudentInformationDidUpdateNotification), object: nil)
  }
  
  private func unregisterForNotifications() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StudentInformationDidUpdateNotification), object: nil)
  }
    
}
