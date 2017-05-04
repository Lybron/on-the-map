//
//  UDYClient.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit
import ReachabilitySwift

class UDYClient: NSObject {
  
  public static let shared = UDYClient()
  public var facebookID: Int?
  public var userID: String = ""
  public var sessionID: String!
  public var userFirstName: String?
  public var userLastName: String?
  
  public func createUdacitySession(credentials: String, completion: @escaping (_ sessionInfo: AnyObject?, _ error:NSError?) -> Void) {
    let url = udacityAPIURLWith(pathExtension: UDYClient.APIPathExtensions.session, parameters: [:])
    
    let request = URLRequest.from(url: url, headers: UDYClient.APIHeaders.postHeaders, httpMethod: "POST", httpBody: credentials)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
  }
  
  public func getUdacityUser(userID: String, completion: @escaping (_ userInfo: AnyObject?, _ error: NSError?) -> Void ) {
    
    let url = udacityAPIURLWith(pathExtension: UDYClient.APIPathExtensions.user + "/\(userID)", parameters: [:])
    
    let request = URLRequest.from(url: url, headers: [:], httpMethod: "GET", httpBody: nil)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
  }
  
  public func deleteUdacitySession(completion: @escaping (_ sessionInfo: AnyObject?, _ error: NSError?) -> Void) {
    let url = udacityAPIURLWith(pathExtension: UDYClient.APIPathExtensions.session, parameters: [:])
    
    var headers = [String:AnyObject]()
    
    var xsrfCookie: HTTPCookie? = nil
    
    let sharedCookieStorage = HTTPCookieStorage.shared
    
    for cookie in sharedCookieStorage.cookies! {
      if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    
    if let xsrfCookie = xsrfCookie {
      headers["X-XSRF-TOKEN"] = xsrfCookie.value as AnyObject
    }
    
    let request = URLRequest.from(url: url, headers: headers, httpMethod: "DELETE", httpBody: nil)
    
    createTask(request: request) { (result, error) in
      completion(result, error)
    }
    
  }
  
  private func createTask(request: URLRequest, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
    let task = URLSessionDataTask.task(request: request) { (data, error) in
      
      if error != nil {
        completion(nil, error as? NSError)
        return
      }
      
      guard let data = data else {
        completion(nil, NSError(domain: "createTask", code: 1, userInfo: [NSLocalizedDescriptionKey:"The requested data is unavailable. Please try again."]))
        return
      }
      
      let parsedJSON = self.parseUdacityData(data)
      completion(parsedJSON, nil)
      
    }
    
    DispatchQueue.global().async {
      task.resume()
    }
    
  }
  
  private func parseUdacityData(_ data: Data) -> AnyObject? {
    
    let range = Range(5 ..< data.count)
    let newData = data.subdata(in: range)
    let info = NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!
    
    let newString = "\(info)"
        
    let udacityData = newString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    
    do {
      let json = try JSONSerialization.jsonObject(with: udacityData, options: []) as! [String: AnyObject]
      
      return json as AnyObject
      
    } catch {
      return nil
    }
    
  }
  
  private func udacityAPIURLWith(pathExtension: String, parameters: [String:AnyObject]) -> URL {
    
    let url = URL.from(
      scheme: UDYClient.BaseURLComponents.scheme,
      host: UDYClient.BaseURLComponents.host,
      path: UDYClient.BaseURLComponents.path,
      pathExtension: pathExtension,
      parameters: parameters)
    
    return url
  }
  
  private override init(){}

}
