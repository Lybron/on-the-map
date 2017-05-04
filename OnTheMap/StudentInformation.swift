//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/11/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import Foundation

class StudentInformation {
  let objectId: String
  let uniqueKey: String
  let firstName: String
  let lastName: String
  var mapString: String
  var mediaURL: String
  var latitude: Float
  var longitude: Float
  
  init(_ information: [String:AnyObject]) {
    self.objectId = information["objectId"] as? String ?? ""
    self.uniqueKey = information["uniqueKey"] as? String ?? ""
    self.firstName = information["firstName"] as? String ?? ""
    self.lastName = information["lastName"] as? String ?? ""
    self.mapString = information["mapString"] as? String ?? ""
    self.mediaURL = information["mediaURL"] as? String ?? ""
    self.latitude = information["latitude"] as? Float ?? 0.0
    self.longitude = information["longitude"] as? Float ?? 0.0
  }
}

extension StudentInformation {
  
  func info() -> [String:AnyObject] {
    return [
      "objectId": self.objectId as AnyObject,
      "uniqueKey": self.uniqueKey as AnyObject,
      "firstName": self.firstName as AnyObject,
      "lastName": self.lastName as AnyObject,
      "mapString": self.mapString as AnyObject,
      "mediaURL": self.mediaURL as AnyObject,
      "latitude": self.latitude as AnyObject,
      "longitude": self.longitude as AnyObject
    ]
  }
}
