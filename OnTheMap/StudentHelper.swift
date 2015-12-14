//
//  StudentHelper.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/10/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import Foundation


class StudentHelper : NSObject {
    
    var students = [StudentInformation]()
    var currentStudent = StudentInformation()
    
    
    class func sharedInstance() -> StudentHelper {
        
        struct Singleton {
            static var sharedInstance = StudentHelper()
        }
        
        return Singleton.sharedInstance
    }
}