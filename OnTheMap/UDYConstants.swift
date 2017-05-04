//
//  UDYConstants.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

extension UDYClient {
  
  static let UdacitySignUpURL = "https://www.udacity.com/account/auth#!/signup"
  
  struct BaseURLComponents {
    static let scheme = "https://"
    static let host = "www.udacity.com"
    static let path = "/api"
  }
  
  struct APIPathExtensions {
    static let session = "/session"
    static let user = "/users"
  }
  
  struct APIHeaders {
    static let postHeaders = [
      "Accept":"application/json" as AnyObject,
      "Content-Type":"application/json" as AnyObject
    ] as [String:AnyObject]
  }
  
  struct APIRequestParameters {
    static let studentLocationRequestLimit = 100
    static let studentLocationsRequestSkipInterval = 0
    static let studentLocationsRequestOrder = "-updatedAt"
  }
    
}
