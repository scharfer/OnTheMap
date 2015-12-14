//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/10/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import Foundation


struct StudentInformation {
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var firstName : String = ""
    var lastName: String = ""
    var mediaURL: String = ""
    var updatedDate : String = ""
    var studentId : String = ""
    var sessionId : String = ""
    
    init() {
        // nothing here
    }
    
    init(values : NSDictionary) {
        firstName = values["firstName"] as! String
        lastName = values["lastName"] as! String
        latitude = values["latitude"] as! Double
        longitude = values["longitude"] as! Double
        mediaURL = values["mediaURL"] as! String
        updatedDate = values["updatedAt"] as! String
    }
    
}