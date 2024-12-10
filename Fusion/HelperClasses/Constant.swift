//
//  Constant.swift
//  Fusion
//
//  Created by meet sharma on 12/01/23.
//


import Foundation
import UIKit

let baseURL = ""

public typealias parameters = [String:Any]
var noInternetConnection = "No Internet Connection Available"


//MARK:- StoryBoard


//STORE FILE
enum DefaultKeys: String{
    case authKey
    case autoLogin
    case userDetails
    case id
    case email
    case isVibrationOn
    case security_key
    case Authorization
    case imageSize
    case imageUrl
    case latestImgUrl
    case showMessage
}


//MARK: API - SERVICES
enum Services: String
{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

//MARK: API - ENUM
enum API: String
{
    
    case uploadImg = "https://api.imgbb.com/1/upload"

}



enum constantMessages:String{
    
    case internetError    = "Please check your internet connectivity"

    var instance : String {
        return self.rawValue
    }
}
