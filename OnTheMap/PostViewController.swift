//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import QuartzCore

class PostViewController: UIViewController {
  
  // MRK: Properties
  public var locationID: String?
  
  private var placemark: CLPlacemark?
  
  // MARK: IBOutlets
  @IBOutlet weak var entryTextfield: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    entryTextfield.delegate = self
    configureGeocodingUI()
    roundRectButtons()
  }
  
  // MARK: CLGeocoder
  func findOnMap(_ address: String) {
    if address.characters.count == 0 { return }
    
    enableUI(false)
    
    let geoCoder = CLGeocoder()
    geoCoder.geocodeAddressString(address) { (result: [CLPlacemark]?, error: Error?) in
      
      self.enableUI(true)
      
      guard error == nil else {
        self.handleError(NSError(domain: "geocodeAddress", code: 1, userInfo: [NSLocalizedDescriptionKey:"Your location could not be determined. Please try again."]))
        return
      }
      
      if let placemarks = result as [CLPlacemark]!, placemarks.count > 0 {
        self.placemark = placemarks[0]
        self.setMapCoordinate(self.placemark)
        
        DispatchQueue.main.async {
          self.configureMediaURLUI()
        }
      }
    }
  }
  
  // MARK: UI Helpers
  private func enableUI(_ enabled: Bool) {
    DispatchQueue.main.async {
      self.entryTextfield.isUserInteractionEnabled = enabled
      self.searchButton.isUserInteractionEnabled = enabled
      self.submitButton.isEnabled = enabled
      
      if enabled {
        self.title = "Post Your Location"
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.view.alpha = 1.0
      } else {
        self.title = "Loading..."
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.view.insertSubview(self.activityIndicator, aboveSubview: self.mapView)
        self.view.alpha = 0.8
      }
    }
  }
  
  private func configureGeocodingUI() {
    DispatchQueue.main.async {
      self.entryTextfield.placeholder = "Where are you located?"
      self.searchButton.isHidden = false
      self.submitButton.isHidden = true
    }
  }
  
  private func configureMediaURLUI() {
    DispatchQueue.main.async {
      self.entryTextfield.text = ""
      self.entryTextfield.placeholder = "Where can we find you online?"
      self.entryTextfield.autocapitalizationType = .none
      self.entryTextfield.autocorrectionType = .no
      self.searchButton.isHidden = true
      self.submitButton.isHidden = false
      self.submitButton.isEnabled = false
    }
  }
  
  private func roundRectButtons() {
    self.searchButton.layer.cornerRadius = 5.0
    self.submitButton.layer.cornerRadius = 5.0
  }
  
  private func setMapCoordinate(_ placemark: CLPlacemark?) {
    
    guard let placemark = placemark else { return }
    
    let latitude = CLLocationDegrees(placemark.location!.coordinate.latitude)
    let longitude = CLLocationDegrees(placemark.location!.coordinate.longitude)
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = placemark.name
    annotation.subtitle = "You are here"
    
    let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: MKCoordinateSpanMake(0.02, 0.02))
    
    DispatchQueue.main.async {
      self.mapView.setRegion(region, animated: true)
      self.mapView.addAnnotations([annotation])
    }
  }
  
  func submitLocation() {
    if entryTextfield.text!.isEmpty { return }
    
    if let _ = locationID {
      updateLocation(locationID!, placemark: placemark)
    } else {
      addLocation(placemark)
    }
  }

  // MARK: IBActions
  @IBAction func cancelButtonPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func searchButtonPressed(_ sender: Any) {
    self.view.endEditing(true)
    findOnMap(entryTextfield.text!)
  }
  
  @IBAction func submitButtonPressed(_ sender: Any) {
    submitLocation()
  }
  
  // MARK: Parse Client
  private func updateLocation(_ locationID: String, placemark: CLPlacemark?) {
    guard let placemark = placemark else {
      handleError(placemarkError())
      return
    }
    
    enableUI(false)
    
    let locationInfo = jsonStringFrom(placemark: placemark, mediaURL: entryTextfield.text!)
    
    ParseClient.shared.updateStudentLocation(locationID: locationID, postBody: locationInfo) { (result, error) in
      
      self.enableUI(true)
      
      guard  error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let res = result as? [String:AnyObject] else {
        return
      }
      
      if let _ = res["updatedAt"] as? String {
        self.refreshData()
      }
    }
  }
  
  private func addLocation(_ placemark: CLPlacemark?) {
    guard let placemark = placemark else {
      handleError(placemarkError())
      return
    }
    
    enableUI(false)
    
    let locationInfo = jsonStringFrom(placemark: placemark, mediaURL: entryTextfield.text!)
    
    ParseClient.shared.addStudentLocation(postBody: locationInfo) { (result, error) in
      
      self.enableUI(true)
      
      guard  error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let result = result as? [String:AnyObject] else {
        return
      }
      
      if let _ = result["objectId"] as? String {
        self.refreshData()
      }
    }
  }
  
  private func jsonStringFrom(placemark: CLPlacemark, mediaURL: String) -> String {
    let firstName = UDYClient.shared.userFirstName ?? ""
    let lastName = UDYClient.shared.userLastName ?? ""
    return "{\"uniqueKey\": \"\(UDYClient.shared.userID)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(placemark.name!)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(placemark.location!.coordinate.latitude), \"longitude\": \(placemark.location!.coordinate.longitude)}"
  }
  
  private func refreshData() {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "unwindToTabControllerSegue", sender: self)
    }
  }
  
  private func placemarkError() -> NSError {
    return NSError(domain: "placemarkError", code: 1, userInfo: [NSLocalizedDescriptionKey: "You have not set your location."])
  }
  
}

extension PostViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    searchButton.isEnabled = !textField.text!.isEmpty
    submitButton.isEnabled = !textField.text!.isEmpty
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension PostViewController: MKMapViewDelegate {}
