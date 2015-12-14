//
//  MapViewTableViewController.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/11/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import UIKit

class MapViewTableViewController: UITableViewController {
    
    let students = StudentHelper.sharedInstance().students.sort({ $0.updatedDate > $1.updatedDate })

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)

        // Configure the cell...
        let student = students[indexPath.row]
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"        

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // push table down because of navigation controller
        return 55.0
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // open media url on click
        let student = students[indexPath.row]
        if student.mediaURL != "" {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: student.mediaURL)!)
        }

    }
    

}
