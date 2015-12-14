//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/9/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser = StudentInformation()

    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.secureTextEntry = true
        
        userName.delegate = self
        
        password.delegate = self
    }

    @IBAction func login(sender: AnyObject) {
        
        let requestData = ["udacity":["username":userName.text!,"password":password.text!]]
        
        MapWSClient.sharedInstance().makeWSRequest(MapConstants.UdacitySessionURL, params : nil, requestType : "POST", requestData: requestData, headerAttrs: nil, skipFirstFive: true, callBack : requestSessionResult)
    }
    
    func requestSessionResult (result: AnyObject?, error: NSError? ) {
        if var error = error {
            if error.code == 100 {
                error = NSError(domain: "WSCall", code: 100, userInfo: [NSLocalizedDescriptionKey:"Invalid Login / Password"])
            }
            // display error alert
            displayError(error)
            
        } else if let result = result {
            let sessionId = result["session"]??["id"] as! String
            let userId = result["account"]??["key"] as! String
            
            currentUser.sessionId = sessionId
            currentUser.studentId = userId
                    
            var userUrl = MapConstants.UdacityUserURL
            userUrl += "\(userId)"
            print(userUrl)
            MapWSClient.sharedInstance().makeWSRequest(userUrl, params : nil, requestType : "GET", requestData: nil, headerAttrs: nil, skipFirstFive: true, callBack : requestUserResult)
            
        }
        
    }
    
    func requestUserResult (result: AnyObject?, error: NSError?) {
        if let error = error {
            // display error alert
            
            displayError(error)
            // do error modal
        } else if let result = result {
            
            let firstName = result["user"]??["first_name"] as! String
            let lastName = result["user"]??["last_name"] as! String
            
            currentUser.firstName = firstName
            currentUser.lastName = lastName
            StudentHelper.sharedInstance().currentStudent = currentUser
            
            let requestHeaderData = [MapConstants.ParseAppKey : MapConstants.ParseAppId, MapConstants.ParseAPIKey : MapConstants.ParseAPI]
            
            // request for the locations of users
            MapWSClient.sharedInstance().makeWSRequest(MapConstants.StudentURL, params : nil, requestType : "GET", requestData: nil, headerAttrs: requestHeaderData, skipFirstFive: false, callBack : requestLocationsResult)
        }
    }
    
    func requestLocationsResult (result: AnyObject?, error: NSError? ) {
        
        if let error = error {
            // display error alert
            displayError(error)
            // do error modal
        } else if let result = result {
            
            let students = result["results"] as? [[String : AnyObject]]
            
            for student in students! {
                let studentObj = StudentInformation(values: student)
                StudentHelper.sharedInstance().students.append(studentObj)
            }
    
            
            dispatch_async(dispatch_get_main_queue(), {
                //self.debugTextLabel.text = ""
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! UINavigationController
                // set locations to controller
                
                self.presentViewController(controller, animated: true, completion: nil)
            })
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    
    func displayError(error : NSError) {
        
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .ActionSheet)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler : nil)
        alertController.addAction(OKAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    

}

