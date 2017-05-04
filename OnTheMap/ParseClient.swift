//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
  
  public static let shared = ParseClient()
  
  // Get Student Locations
  public func getStudentLocations(queryParameters: [String:AnyObject], completion: @escaping (_ info: AnyObject?, _ error: NSError?) -> Void) {
    let url = parseAPIURLWith(pathExtension: ParseClient.APIPathExtensions.studentLocation, parameters: queryParameters)
    
    let request = URLRequest.from(url: url, headers: ParseClient.apiHeaders, httpMethod: "GET", httpBody: nil)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
    
  }
  
  // Get Student Location - Single
  public func getStudentLocation(queryParameters: [String:AnyObject], completion: @escaping (_ info: AnyObject?, _ error:NSError?) -> Void) {
    
    let url = parseAPIURLWith(pathExtension: ParseClient.APIPathExtensions.studentLocation, parameters: queryParameters)
    
    let request = URLRequest.from(url: url, headers: ParseClient.apiHeaders, httpMethod: "GET", httpBody: nil)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
  }
  
  // Add Student Location
  public func addStudentLocation(postBody: String, completion: @escaping (_ info: AnyObject?, _ error:NSError?) -> Void) {
    
    var headers = ParseClient.apiHeaders
    headers["Content-Type"] = "application/json" as AnyObject
    
    let url = parseAPIURLWith(pathExtension: ParseClient.APIPathExtensions.studentLocation, parameters: [:])
    
    let request = URLRequest.from(url: url, headers: headers, httpMethod: "POST", httpBody: postBody)
    
    createTask(request: request as URLRequest) { (result, error) in
      completion(result, error)
    }
  }
  
  // Update Student Location
  public func updateStudentLocation(locationID: String, postBody: String, completion: @escaping (_ info: AnyObject?, _ error:NSError?) -> Void) {
    
    var headers = ParseClient.apiHeaders
    headers["Content-Type"] = "application/json" as AnyObject

    
    let url = parseAPIURLWith(pathExtension: ParseClient.APIPathExtensions.studentLocation + "/\(locationID)", parameters: [:])
    
    let request = URLRequest.from(url: url, headers: headers, httpMethod: "PUT", httpBody: postBody)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
  }
  
  private func createTask(request: URLRequest, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
    let task = URLSessionDataTask.task(request: request) { (data, error) in
      
      if error != nil {
        completion(nil, error as NSError?)
      }
      
      guard let data = data else {
        completion(nil, error as NSError?)
        return
      }
      
      let parsedJSON = self.parseParseData(data)
      completion(parsedJSON, nil)
      
    }
    
    DispatchQueue.global().async {
      task.resume()
    }
  }

  private func parseParseData(_ data: Data) -> AnyObject? {
    let info = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
    
    let newString = "\(info)"
    
    let parseData = newString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    
    do {
      let json = try JSONSerialization.jsonObject(with: parseData, options: []) as! [String: AnyObject]
      
      return json as AnyObject
      
    } catch {
      
      return nil
    }
  }
  
  private func parseAPIURLWith(pathExtension: String, parameters: [String:AnyObject]) -> URL {
        
    let url = URL.from(
      scheme: ParseClient.BaseURLComponents.scheme,
      host: ParseClient.BaseURLComponents.host,
      path: ParseClient.BaseURLComponents.path,
      pathExtension: pathExtension,
      parameters: parameters)
    
    return url
  }
  
  private override init() {}

}
