
//
//  APIRequest.swift
//  AffroppleApp
//
//  Created by apple on 11/09/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

struct WebService {
    static var spinner : NVActivityIndicatorView?
    static let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    
    static func service<Model: Codable>(_ api:API, urlAppendId: Any? = nil,param: Any? = nil, service: Services = .post ,showHud: Bool = true, headerAppendId: String? = nil,is_raw_form:Bool = false,response:@escaping (Model,Data,Any) -> Void)
    {
        
        if Reachability.isConnectedToNetwork()
            
        {
            
            var fullUrlString = api.rawValue
            if let idApend = urlAppendId
            {
                fullUrlString =  api.rawValue + "/\(idApend)"
            }
            if service == .get{
                if let parm = param{
                    if parm is String{
                        fullUrlString.append("?")
                        fullUrlString += (parm as! String)
                    }else if parm is Dictionary<String, Any>{
                        fullUrlString += self.getString(from: parm as! Dictionary<String, Any>)
                    }else{
                        assertionFailure("Parameter must be Dictionary or String.")
                    }
                }
            }
            print(fullUrlString)
            guard let encodedString = fullUrlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {return}
            var request = URLRequest(url: URL(string: encodedString)!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 2000)
            
            request.httpMethod = service.rawValue
            
            if let authKey = Store.authKey ,Store.authKey != nil ,Store.authKey != ""
            {
                print(authKey)
                let auth = "Bearer " + authKey
                request.addValue(auth, forHTTPHeaderField: DefaultKeys.Authorization.rawValue)
            }
            
            request.addValue("", forHTTPHeaderField: DefaultKeys.security_key.rawValue)
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            if service == .delete {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let param = param{
                    if param is String{
                        let postData = NSMutableData(data: (param as! String).data(using: String.Encoding.utf8)!)
                        request.httpBody = postData as Data
                    }else if param is Dictionary<String, Any>{
                        var parm = self.getString(from: param as! Dictionary<String, Any>)
                        //print(parm)
                        parm.removeFirst()
                        let postData = NSMutableData(data: parm.data(using: String.Encoding.utf8)!)
                        request.httpBody = postData as Data
                    }
                }
            }
            
            
            
            if service == .post || service == .put{
                if let parameter = param{
                    if parameter is String{
                        request.httpBody = (parameter as! String).data(using: .utf8)
                    }else if parameter is Dictionary<String, Any>{
                        var body = Data()
                        for (key, Value) in parameter as! Dictionary<String, Any>{
                            //print(key,Value)
                            if let imageInfo = Value as? ImageStructInfo{
                                body.append("--\(boundary)\r\n")
                                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(imageInfo.fileName)\"\r\n")
                                body.append("Content-Type: \(imageInfo.type)\r\n\r\n")
                                body.append(imageInfo.data)
                                body.append("\r\n")
                            }
                            else if let images = Value as? [ImageStructInfo]{
                                for value in images{
                                    body.append("--\(boundary)\r\n")
                                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(value.fileName)\"\r\n")
                                    body.append("Content-Type: \(value.type)\r\n\r\n")
                                    body.append(value.data)
                                    body.append("\r\n")
                                }
                            }else{
                                body.append("--\(boundary)\r\n")
                                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                                body.append("\(Value)\r\n")
                            }
                        }
                        body.append("--\(boundary)--\r\n")
                        request.httpBody = body
                    }else{
                        assertionFailure("Parameter must be Dictionary or String.")
                    }
                }
            }
            
            //MARK:- Raw form : send param in raw form
            if is_raw_form == true{
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let parameters = param as! [String:Any]
                let postData = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
                request.httpBody = postData
            }
    
            
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
//            if showHud{
//                showLoader()
//            }
            session.dataTask(with: request) { (data, jsonResponse, error) in
//                if showHud{
//                    DispatchQueue.main.async {
//                        hideLoader()
//                    }
//                }
                
                if error != nil{
                    WebService.showAlert(error!.localizedDescription)
                }else{
                    if let jsonData = data{
                        do{
                            let jsonSer = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String: Any]
                            print(jsonSer)
                          
                                let decoder = JSONDecoder()
                                let model = try decoder.decode(Model.self, from: jsonData)
                                DispatchQueue.main.async {
                                    response(model,jsonData,jsonSer)
                                
                            }
                        }catch let err{
                            print(err)
                            
                            WebService.showAlert(err.localizedDescription)
                        }
                    }
                }
            }.resume()
        }
        else
        {
            self.showAlert(constantMessages.internetError.instance)
        }
    }
    
    private static func showAlert(_ message: String){
        DispatchQueue.main.async {
            showSwiftyAlert("", message, false)
        }
    }
    private static func showLoader()
    {
        spinner =  NVActivityIndicatorView.init(frame: (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.frame) ?? CGRect(x: 0, y: 0, width: 320, height: 568), type: .lineSpinFadeLoader, color: .white, padding: 170)
        spinner?.startAnimating()
       
        (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(spinner!))
        spinner?.startAnimating()
    }
    
     static func hideLoader()
    {
        DispatchQueue.main.async {
        spinner?.stopAnimating()
        }
    }
    
    
    private static func getString(from dict: Dictionary<String,Any>) -> String{
        var stringDict = String()
        stringDict.append("?")
        for (key, value) in dict{
            let param = key + "=" + "\(value)"
            stringDict.append(param)
            stringDict.append("&")
        }
        stringDict.removeLast()
        return stringDict
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8){
            append(data)
        }
    }
}

extension UIImage {
    func toData() -> Data{
        return self.jpegData(compressionQuality: 0.5)!
    }
    func isEqualToImage(image: UIImage) -> Bool
    {
        let data1: Data = self.pngData()!
        let data2: Data = image.pngData()!
        return data1 == data2
    }
}

struct ImageStructInfo {
    var fileName: String
    var type: String
    var data: Data
    var key:String
}

