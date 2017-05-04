//
//  MapViewController+MKMapViewDelegate.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/11/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import Foundation
import MapKit
import SafariServices

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }
    
    return pinView
  }
    
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == view.rightCalloutAccessoryView {
      if let mediaURL = view.annotation?.subtitle! {
        openURLInSafari(mediaURL)
      }
    }
  }
  
}
