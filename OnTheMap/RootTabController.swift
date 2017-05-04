//
//  RootTabController.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit

class RootTabController: UITabBarController {
  
  // MARK: Properties
  private var currentLocation: StudentInformation?
  private var currentLocationID: String?
  
  // MARK: IBOutlets
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  @IBOutlet weak var pinButton: UIBarButtonItem!
  @IBOutlet weak var logoutButton: UIBarButtonItem!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    getStudentLocations()
  }
  
  // MARK: Add/Update Location
  @IBAction func postLocation(_ sender: Any) {
    let modalNavController = storyboard?.instantiateViewController(withIdentifier: "PostNavController") as! UINavigationController
    let postController = modalNavController.childViewControllers[0] as! PostViewController
    postController.locationID = self.currentLocationID
    present(modalNavController, animated: true, completion: nil)
  }
  
  @IBAction func refreshLocations(_ sender: Any) {
    getStudentLocations()
  }
  
  // MARK: Helpers
  private func enableUI(_ enabled: Bool) {
    DispatchQueue.main.async {
      if enabled {
        self.title = "On The Map"
        self.refreshButton.isEnabled = enabled
        self.pinButton.isEnabled = enabled
        self.logoutButton.isEnabled = enabled
        self.view.alpha = 1.0
      } else {
        self.title = "Loading..."
        self.refreshButton.isEnabled = enabled
        self.pinButton.isEnabled = enabled
        self.logoutButton.isEnabled = enabled
        self.view.alpha = 0.8
      }
    }
  }
  
  // MARK: Get Student Locations
  private func getStudentLocations() {
    enableUI(false)
    
    let params = [
      "limit": UDYClient.APIRequestParameters.studentLocationRequestLimit as AnyObject,
      "skip": UDYClient.APIRequestParameters.studentLocationsRequestSkipInterval as AnyObject,
      "order": UDYClient.APIRequestParameters.studentLocationsRequestOrder as AnyObject
    ]
    
    ParseClient.shared.getStudentLocations(queryParameters: params) { (locations, error) in
      self.enableUI(true)
            
      guard error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let locs = locations as? [String:AnyObject], let array = locs["results"] as? [[String:AnyObject]] else { return }
      
      StudentInformationStore.shared.students.removeAll()
      
      for location in array {
        let student = StudentInformation(location)
        StudentInformationStore.shared.students.append(student)
      }
      
      self.getStudentInformation()
    }
  }
  
  // MARK: Get Student Location
  private func getStudentInformation() {
    enableUI(false)
    
    let params = [
      "where": "{\"uniqueKey\":\"\(UDYClient.shared.userID)\"}" as AnyObject
      ] as [String:AnyObject]
    
    ParseClient.shared.getStudentLocation(queryParameters: params) { (locations, error) in
      self.enableUI(true)
      
      guard error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let locations = locations as? [String:AnyObject], let array = locations["results"] as? [[String:AnyObject]] else {
        return
      }
      
      if !array.isEmpty {
        let studentLocation = array[0]
        
        if let id = studentLocation["objectId"] as? String {
          self.currentLocationID = id 
          self.currentLocation = StudentInformation(studentLocation)
          StudentInformationStore.shared.students.append(StudentInformation(studentLocation))          
        }
      }
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StudentInformationDidUpdateNotification), object: nil)
      }
    }
  }
  
  @IBAction func unwindToTabController(segue:UIStoryboardSegue) {
    refreshLocations(self)
  }
  
  // MARK: Logout Unwind Segue / Delete Session
  @IBAction func logoutUser(_ sender: Any) {
    enableUI(false)
    
    UDYClient.shared.deleteUdacitySession() { (result, error) in
      
      self.enableUI(true)
      
      guard error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let _ = result as? [String:AnyObject] else { return }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: "unwindToLoginSegue", sender: self)
      }      
    }
  }
  
}
