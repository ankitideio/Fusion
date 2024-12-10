//
//  APIClassManager.swift
//  Fusion
//
//  Created by Apple on 02/01/23.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class APIClassManager {
    func postAurhorizationDatatoServer(_ strURL: String,parameter:NSDictionary, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        guard Connectivity.isConnectedToInternet == true else {
            InternetErrorToast(view:UIApplication.shared.windows.first!.rootViewController!, message: "Sorry we cannot reach the internet. Please check your connection.")
            return
        }
        activityIndicatorBegin(view: keyWindow)
        
        let finalUrl = strURL
        print(finalUrl)
        print(parameter)
        let header : HTTPHeaders = ["Authorization":"Bearer \(apiKey)"]
        print(header)
        AF.request(finalUrl, method: .post, parameters: parameter as? Parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (responseObject) -> Void in
            if responseObject.value != nil {
                activityIndicatorEnd(view: keyWindow)
                let resJson = JSON(responseObject.value!)
                success(resJson)
            }
            if responseObject.value == nil {
                activityIndicatorEnd(view: keyWindow)
                let error : Error = responseObject.error!
                failure(error)
                print(error)
            }
            
        }
    }
}
