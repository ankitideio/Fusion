//
//  ModelCreateImageResponse.swift
//  Fusion
//
//  Created by Apple on 02/01/23.
//

import UIKit
//
class ModelCreateImageResponse {

    var arrData = [NodelImageData]()
    
    init(attributes:[String:Any]) {
        let data = attributes["data"]  as? NSArray ?? []
        for dict in data {
            let dictData = NodelImageData.init(attributes: dict as! [String : Any])
            arrData.append(dictData)
        }
    }
    
}

class NodelImageData{
    var url:String?
    
    init(attributes:[String:Any]) {
        url = attributes["url"] as? String
    }
}




struct DALLEResponse: Decodable {
    let created: Int
    let data: [Photo]
}

struct Photo: Decodable {
    let url: URL
}
