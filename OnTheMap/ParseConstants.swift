//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import Foundation

extension ParseClient {
  struct BaseURLComponents {
    static let scheme = "https://"
    static let host = "parse.udacity.com"
    static let path = "/parse/classes"
  }
  
  struct APIPathExtensions {
    static let studentLocation = "/StudentLocation"
  }
  
  static let apiHeaders = [
    "X-Parse-Application-Id":"QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" as AnyObject,
    "X-Parse-REST-API-Key":"QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" as AnyObject
  ] as [String:AnyObject]

}
