//
//  LocalePrefrence.swift
//  Empureo
//
//  Created by Apple on 07/10/22.
//

import Foundation
import UIKit

func saveDotStatus(dot:Int){
    UserDefaults.standard.set(dot, forKey: "dot")
}

func fetchDotStatus()-> Int{
    return UserDefaults.standard.value(forKey: "dot") as? Int ?? 0
}
