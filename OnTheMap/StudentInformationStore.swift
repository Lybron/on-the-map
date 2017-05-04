//
//  StudentInformationStore.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/11/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit

class StudentInformationStore: NSObject {
  
  public static let shared = StudentInformationStore()
  
  public var students = [StudentInformation]()
  
  private override init() {}
}
