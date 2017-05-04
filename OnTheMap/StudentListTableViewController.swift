//
//  StudentListTableViewController.swift
//  OnTheMap
//
//  Created by Lybron Sobers on 3/10/17.
//  Copyright © 2017 Lybron Sobers. All rights reserved.
//

import UIKit
import SafariServices

class StudentListTableViewController: UITableViewController {
  private let reuseIdentifier = "StudentCell"
  private var students = StudentInformationStore.shared.students
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerForNotifications()
    reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    unregisterForNotifications()
  }
  
  @objc func reloadData() {
    self.students = StudentInformationStore.shared.students
    self.tableView.reloadData()
  }
    
  // MARK: - Table view data source & Delegate
    
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return students.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as UITableViewCell
    let student = students[indexPath.row]
    
    cell.textLabel?.text = student.firstName + " " + student.lastName
    cell.imageView?.image = UIImage(named: "pin-60")
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let student = students[indexPath.row]
    openURLInSafari(student.mediaURL)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // MARK: Notifications
  private func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: StudentInformationDidUpdateNotification), object: nil)
  }
  
  private func unregisterForNotifications() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StudentInformationDidUpdateNotification), object: nil)
  }
  
}
