//
//  UIViewController+Alerts.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/12/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension UIViewController {
  func handleError(_ error: NSError) {
    
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func openURLInSafari(_ string: String) {
    
    if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      handleError(NSError(domain: "invalidURL", code: 1, userInfo: [NSLocalizedDescriptionKey: "The action could not be completed because you are attempting to open an invalid URL."]))
    }
    
  }
}
