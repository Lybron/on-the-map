//
//  URL+Parameters.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/11/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import Foundation
import UIKit

enum OTMNetworkError: String {
  case networkDisconnectedError = "It seems you are not connected to the Internet. Please check your connection and try again."
  case noDataError = "The request was successful but the data could not be processed. Please contact support if this issue continues."
  case authorizationError = "You are not authorized to make this request. Please check your email and/or password."
  case requestError = "The request failed. Please try again, or contact suppoert if this issue continues."
}

extension URL {
  public static func from(scheme: String, host: String, path: String, pathExtension: String?, parameters: [String:AnyObject]) -> URL {
    
    let string = scheme + host + path + (pathExtension ?? "")
    
    var components = URLComponents(string: string)

    var items = [URLQueryItem]()
    
    for (key, value) in parameters {
      let queryItem = URLQueryItem(name: key, value: "\(value)")
      items.append(queryItem)
    }
    
    if items.count > 0 { components?.queryItems = items }
    
    return components!.url!
  }

}

extension URLRequest {
  public static func from(url: URL, headers: [String:AnyObject], httpMethod: String, httpBody: String?) -> URLRequest {
    let request = NSMutableURLRequest(url: url)
    
    request.httpMethod = httpMethod
        
    if let string = httpBody {
      request.httpBody = string.data(using: String.Encoding.utf8)
    }
    
    for (field, value) in headers {
      request.addValue(value as! String, forHTTPHeaderField: field)
    }
    
    return request as URLRequest
  }
  
}

extension URLSessionDataTask {
  public static func task(request: URLRequest, completion: @escaping (_ result: Data?, _ networkError: Error?) -> Void) -> URLSessionDataTask {
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      
      func sendError(_ error: OTMNetworkError) {
        let userInfo = [NSLocalizedDescriptionKey : error.rawValue]
        completion(nil, NSError(domain: "otmURLSessionDataTask", code: 1, userInfo: userInfo))
      }
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      
      if !appDelegate.reachability.isReachable {
        sendError(.networkDisconnectedError)
        return
      }
      
      guard error == nil else {
        sendError(.requestError)
        return
      }
            
      if let response = response as? HTTPURLResponse,  response.statusCode == 403 {
        sendError(.authorizationError)
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
        sendError(.requestError)
        return
      }
      
      guard let data = data else {
        sendError(.noDataError)
        return
      }
      
      completion(data, nil)
      
    })
    
    return task
  }

}
