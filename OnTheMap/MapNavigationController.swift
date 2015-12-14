//
//  MapNavigationController.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/11/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import UIKit

class MapNavigationController: UITabBarController {

    @IBAction func logout(sender: AnyObject) {
        let currentStudent = StudentHelper.sharedInstance().currentStudent
        
        let requestHeaderData = ["X-XSRF-TOKEN" : currentStudent.sessionId]
        
        // save the location
        MapWSClient.sharedInstance().makeWSRequest(MapConstants.UdacitySessionURL, params : nil, requestType : "DELETE", requestData: nil, headerAttrs: requestHeaderData, skipFirstFive: true, callBack : logoutResult)

    }
    
    func logoutResult (result: AnyObject?, error: NSError? ) {
        print(error)
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
            // set locations to controller
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
}
