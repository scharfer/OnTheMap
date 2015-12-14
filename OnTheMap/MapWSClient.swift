//
//  MapWSClient.swift
//  OnTheMap
//
//  Created by Evan Scharfer on 12/9/15.
//  Copyright © 2015 Evan Scharfer. All rights reserved.
//

import Foundation

class MapWSClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    func makeWSRequest(url: String, params : [String : AnyObject]?, requestType : String, requestData: [String:AnyObject]?, headerAttrs: [String:String]?, skipFirstFive : Bool, callBack : (result: AnyObject?, error: NSError? ) -> Void) -> NSURLSessionDataTask {
        
        
        /* 2/3. Build the URL and configure the request */
        var urlString = url
        if let params = params {
            urlString += escapedParameters(params)
        }
        
        //print("url: \(urlString)")
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = requestType
        
        if let requestData = requestData {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(requestData, options: .PrettyPrinted)
                //let test = try! NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .AllowFragments)
                //print("body: \(test)")
            }
        }
        
        if let headerAttrs = headerAttrs {
            for (key, value) in headerAttrs {
                request.addValue(value, forHTTPHeaderField: key)
                
            }
            //print("header: \(headerAttrs)")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                callBack(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                let error = NSError(domain: "WSCall", code: 100, userInfo: [NSLocalizedDescriptionKey:"Invalid Status Returned"])
                callBack(result: nil, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                let error = NSError(domain: "WSCall", code: 101, userInfo: [NSLocalizedDescriptionKey:"Server Issue! Please try again later."])
                callBack(result: nil, error: error)
                return
            }
            var parsedResult: AnyObject!
            do {
                var newData = data
                if (skipFirstFive ) {
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                callBack(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 102, userInfo: userInfo))
            }
            
            callBack(result: parsedResult, error: nil)
            
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task

        
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> MapWSClient {
        
        struct Singleton {
            static var sharedInstance = MapWSClient()
        }
        
        return Singleton.sharedInstance
    }


}
