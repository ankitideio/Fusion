//
//  GlobalFunctions.swift
//  FoodTigerMerchantApp
//
//  Created by Ankit KaleRamans on 24/04/20.
//  Copyright © 2020 Ankit Jaat. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import Loaf

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}

var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
let greyView = UIView()
let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!

func activityIndicatorBegin(view:UIView) {
    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    //activityIndicator.style = UIActivityIndicatorView.Style.gray
    view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    activityIndicator.color = .green
    view.isUserInteractionEnabled = false
    activityIndicator.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
    //activityIndicator.style = UIActivityIndicatorView.Style.medium
    greyView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    greyView.backgroundColor = UIColor.black
    greyView.alpha = 0.3
    view.addSubview(greyView)
}

func activityIndicatorEnd(view:UIView) {
    activityIndicator.stopAnimating()
    view.isUserInteractionEnabled = true
    greyView.removeFromSuperview()
}

func InternetErrorToast(view:UIViewController,message:String)  {
    
    Loaf(message, state: .error, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: view ).show()
}

func TostErrorMessage(view:UIViewController,message:String)  {
    
    Loaf(message, state: .warning, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: view ).show()
}

func sucessToast(view:UIViewController,message:String)  {
    
    Loaf(message, state: .success, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: view ).show()
}

func convertStringToDate(dateConvert:String) -> Date{

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    let date = dateFormatter.date(from:dateConvert)!
    return date
}
func getReadableDate(timeStamp: Date) -> String? {
   // let date = Date(timeIntervalSince1970: timeStamp / 1000)
    let dateFormatter = DateFormatter()

    if Calendar.current.isDateInTomorrow(timeStamp) {
        return "h:mm a | Tomorrow"
    } else if Calendar.current.isDateInYesterday(timeStamp) {
        return "h:mm a | Yesterday"
    } else if dateFallsInCurrentWeek(date: timeStamp) {
        if Calendar.current.isDateInToday(timeStamp) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: timeStamp)
        } else {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: timeStamp)
        }
    } else {
        dateFormatter.dateFormat = "h:mm a | MMM d, yyyy"
        return dateFormatter.string(from: timeStamp)
    }
}

func dateFallsInCurrentWeek(date: Date) -> Bool {
    let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
    let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
    return (currentWeek == datesWeek)
}
