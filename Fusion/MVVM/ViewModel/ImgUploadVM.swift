//
//  ImgUploadVM.swift
//  Fusion
//
//  Created by meet sharma on 23/01/23.
//

import Foundation
import UIKit

class ImgUploadVM{
    func imageUploadApi(image:String,name:String,onSuccess:@escaping((UploadImgModel?)->())){
        let url = URL(string: image)

        let param:parameters = ["image":url ?? URL.self,"key":"d36623083c2f14e287c156053a61bde3","name": name]
                print(param)
        WebService.service(API.uploadImg,param: param,service: .post) {(model: UploadImgModel,jsonData, jsonSer) in
            
            onSuccess(model)

        }
    }

       

      
    }

