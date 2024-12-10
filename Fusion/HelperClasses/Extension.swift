//
//  Extension.swift
//  Fusion
//
//  Created by meet sharma on 11/01/23.
//

import Foundation
import UIKit
import Kingfisher
extension UITextField{
    func isValidEmail() -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result  = emailTest.evaluate(with: self.text)
        return result
    }
}
    extension UIDevice {
        var hasNotch: Bool {
            if #available(iOS 11.0, *) {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
            }
            return false
        }

    }

extension UIImageView{
  
    func imageLoad(imageUrl:String)   {
        let url = URL(string:imageUrl)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: UIImage(named: "no-image"),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
 
 
}
