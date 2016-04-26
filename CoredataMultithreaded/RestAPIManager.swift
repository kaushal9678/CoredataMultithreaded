//
//  RestAPIManager.swift
//  eZnetCRMSwift
//
//  Created by Mahir Abdi on 25/11/15.
//  Copyright © 2015 Mahir Abdi. All rights reserved.
//

import Foundation
import Alamofire
typealias ServiceResponse = (JSON:AnyObject, NSError?) -> Void

class RestAPIManager: NSObject,NSURLSessionDelegate,NSURLSessionTaskDelegate {
   
    let baseURL = "http://199.227.27.197/ecomstandalone/ecom_sakshay_webservices.php?action="
    typealias CallbackBlock = (result: String, error: String?) -> ()
    var callback: CallbackBlock = {
        (resultString, error) -> Void in
        if error == nil {
            print(resultString)
        } else {
            print(error)
        }
    }
    
    static let sharedInstance = RestAPIManager()
  
    
    
    func post(params :NSDictionary, url : String,  postCompleted : (succeeded: Bool, result:NSArray?) -> ()) {
        let URLs = String(format: "%@%@",baseURL,url)
        
        let components =  NSURLComponents(string: URLs)
        //let queryItemEmail = NSURLQueryItem(name: "LoginEmail", value: "pankaj.kumar@vstacks.in")
        //let queryItemPassword = NSURLQueryItem(name: "LoginPassword", value: "Vstacks123#")
       // let queryItemUserType = NSURLQueryItem(name: "UserType", value: "admin")
        let queryItemss = NSMutableArray()
       
         for (key, value) in params {
            
            queryItemss.addObject(NSURLQueryItem(name: key as! String, value: value as? String))
        }
        components?.queryItems = queryItemss as NSArray as? [NSURLQueryItem]
        
       // components?.queryItems = [queryItemEmail,queryItemPassword,queryItemUserType];
        
        
        
        let urls = components!.URL ;
        
        
        
        
        
        let configuration =
        NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration,
            delegate: self,
            delegateQueue:NSOperationQueue.mainQueue())
        
        let request = NSMutableURLRequest(URL: urls!)
       // let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options:[])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            
            do{
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0))as? NSDictionary{
                    
                    if let results = json["result"] as? NSArray{
                        
                        // pass result to completion block
                        postCompleted(succeeded: true,  result: results)
                    }
                    
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, result: nil)
                    
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, result: nil)
                
            }
          
        })
        
        task.resume()
    }
    

    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void){
       
        let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void){
        
    }
    
   //MARK: using alamofire framework post data
    func postparamsUsingAlamofire(params :[String:AnyObject], url : String,  postCompleted : (succeeded: Bool, result:NSDictionary?) -> ())
    {
        let URL = String(format: "%@%@",baseURL,url)
        print(params);
       
        Alamofire.request(.POST, URL, parameters: params)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    //if let results = JSON["result"] as? NSDictionary{
                    if let results = JSON.valueForKey("result") as? NSDictionary{
                        
                        // pass result to completion block
                        postCompleted(succeeded: true,  result: results)
                    }

                }
               
                dispatch_async(dispatch_get_main_queue(), {
                    //SVProgressHUD.showWithStatus("Please wait...", maskType: SVProgressHUDMaskType.Gradient)
                  //  SVProgressHUD.dismiss()
                    
                })
        }
        
    }
    

}


