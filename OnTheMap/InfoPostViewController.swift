//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/10/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController, UITextFieldDelegate {
    
    var latitude : Double!
    var longitude : Double!

    @IBOutlet weak var location: UITextField!
  
    @IBOutlet weak var locationUrl: UITextField!
    
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        activityIndicator.hidden = true
        
        location.delegate = self
        locationUrl.delegate = self
    }
    
    @IBAction func findOnMap(sender: AnyObject) {
        activityIndicator.hidden = false
        let address = location.text!
        if address == "" {
            let locError = NSError(domain: "Location", code: 100, userInfo: [NSLocalizedDescriptionKey:"Please enter a location."])
            displayError(locError)
        } else {
            let geocoder = CLGeocoder()
            
            activityIndicator.startAnimating()
            
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                
                if let error = error {
                    self.displayError(error)
                } else if let placemark = placemarks?.first {
                    print("lat one \(placemark.location!.coordinate.latitude)")
                    self.latitude = placemark.location!.coordinate.latitude
                    self.longitude = placemark.location!.coordinate.longitude
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    self.mapButton.hidden = true
                    self.submitButton.hidden = false
                }
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            })
        }
        
    }
    
    @IBAction func pinLocation(sender: AnyObject) {
        
        let currentStudent = StudentHelper.sharedInstance().currentStudent
        if currentStudent.studentId != "" {
        
            let requestData = ["uniqueKey":currentStudent.studentId,"firstName":currentStudent.firstName,"lastName" : currentStudent.lastName, "mapString":location.text!,"mediaURL": locationUrl.text!, "latitude": latitude, "longitude" : longitude]
            
            let requestHeaderData = [MapConstants.ParseAppKey : MapConstants.ParseAppId, MapConstants.ParseAPIKey : MapConstants.ParseAPI]
            
            // save the location
            MapWSClient.sharedInstance().makeWSRequest(MapConstants.StudentURL, params : nil, requestType : "POST", requestData: requestData as! [String : AnyObject], headerAttrs: requestHeaderData, skipFirstFive: false, callBack : postLocationsResult)
        }
        
    }
    
    @IBAction func cancelPosting(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postLocationsResult (result: AnyObject?, error: NSError? ) {
        
        if let error = error {
            // display error alert
            displayError(error)
            // do error modal
        } else if let result = result {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
