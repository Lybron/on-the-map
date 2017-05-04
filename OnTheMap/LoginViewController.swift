//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  
  // MARK: IBActions
  @IBAction func loginUser(_ sender: Any) {
    createSession()
  }
  
  @IBAction func signUpUser(_ sender: Any) {
    launchWebSignUp()
  }
  
  private func createSession() {
    if !textFieldsValid() { return }
    
    let credentials = "{\"udacity\":{\"username\": \"\(emailTextField.text!)\",\"password\":\"\(passwordTextField.text!)\"}}"

    enableUI(false)
    
    UDYClient.shared.createUdacitySession(credentials: credentials) { (sessionInfo, error) in
      
      self.enableUI( true)
      
      guard error == nil else {
        self.handleError(error!)
        return
      }
            
      if let info = sessionInfo as? [String:AnyObject], let account = info["account"] as? [String:AnyObject], let session = info["session"] as? [String:AnyObject] {
        
        guard let idString = account["key"] as? String else { return }
        guard let sessionID = session["id"] as? String else { return }
        
        let userID = "\(idString)"
        
        UDYClient.shared.sessionID = sessionID

        self.getUser(userID)
      }
    }
  }
  
  private func getUser(_ id: String) {
    UDYClient.shared.getUdacityUser(userID: id) { (userInfo, error) in
      self.enableUI(true)
      
      guard error == nil else {
        self.handleError(error!)
        return
      }
      
      guard let info = userInfo as? [String:AnyObject], let user = info["user"] as? [String:AnyObject], let userID = user["key"] as? String else {
        return
      }
      
      UDYClient.shared.userFirstName = user["first_name"] as? String ?? ""
      UDYClient.shared.userLastName = user["last_name"] as? String ?? ""
      
      UDYClient.shared.userID = "\(userID)"
            
      DispatchQueue.main.async {
        self.completeLogin()
      }
    }
  }
  
  // MARK: Helpers
  private func enableUI(_ enabled: Bool) {
    DispatchQueue.main.async {
      self.emailTextField.isUserInteractionEnabled = enabled
      self.passwordTextField.isUserInteractionEnabled = enabled
      self.loginButton.isEnabled = enabled
      self.signUpButton.isEnabled = enabled
      
      if enabled {
        self.view.alpha = 1.0
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
      } else {
        self.view.alpha = 0.8
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
      }
    }
  }
  
  private func textFieldsValid() -> Bool {
    if emailTextField.text == "" || passwordTextField.text == "" {
      let error = NSError(domain: "loginTextFieldInvalid", code: 1, userInfo: [NSLocalizedDescriptionKey:"You must enter a valid email and password to log in."])
      handleError(error)
      return false
    }
    
    return true
  }
  
  private func launchWebSignUp() {
    openURLInSafari(UDYClient.UdacitySignUpURL)
  }
  
  private func completeLogin() {
    emailTextField.text = nil
    passwordTextField.text = nil
    let controller = storyboard!.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
    present(controller, animated: true, completion: nil)
  }
  
  @IBAction func unwindToLogin(segue:UIStoryboardSegue) {}
  
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
