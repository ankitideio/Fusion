//
//  UserData.swift
//  Fusion
//
//  Created by meet sharma on 12/01/23.
//

import Foundation

class UserData{
    var id:String
    var name: String
    var image:String
    var uid:String
    var updateText:String
    init(id: String, name: String,image:String,uid:String,updateText:String) {
        self.id = id
        self.name = name
        self.image = image
        self.uid = uid
        self.updateText = updateText
    }
}
