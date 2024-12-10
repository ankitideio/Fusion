//
//  Store.swift
//  Fusion
//
//  Created by meet sharma on 12/01/23.
//

import Foundation
class Store {
    

    class var authKey: String?{
        set{
            Store.saveValue(newValue, .authKey)
        }get{
            return Store.getValue(.authKey) as? String
        }
    }
    class var autoLogin: Bool?{
        set{
            Store.saveValue(newValue, .autoLogin)
        }get{
            return Store.getValue(.autoLogin) as? Bool ?? false
        }
    }
  
    class var id: String?{
        set{
            Store.saveValue(newValue, .id)
        }get{
            return Store.getValue(.id) as? String ?? ""
        }
    }
    class var email: String?{
        set{
            Store.saveValue(newValue, .email)
        }get{
            return Store.getValue(.email) as? String ?? ""
        }
    }
    class var imageSize: String?{
        set{
            Store.saveValue(newValue, .imageSize)
        }get{
            return Store.getValue(.imageSize) as? String ?? "1024x1024"
        }
    }

    class var latestImgUrl: String?{
        set{
            Store.saveValue(newValue, .latestImgUrl)
        }get{
            return Store.getValue(.latestImgUrl) as? String ?? ""
        }
    }
    class var isVibrationOn: Bool?{
        set{
            Store.saveValue(newValue, .isVibrationOn)
        }get{
            return Store.getValue(.isVibrationOn) as? Bool ?? true
        }
    }
    class var showMessage: Bool?{
        set{
            Store.saveValue(newValue, .showMessage)
        }get{
            return Store.getValue(.showMessage) as? Bool ?? false
        }
    }
    static var remove: DefaultKeys!{
        didSet{
            Store.removeKey(remove)
        }
    }
    
    //MARK:-  Private Functions
    
    private class func removeKey(_ key: DefaultKeys){
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        if key == .userDetails{
            UserDefaults.standard.removeObject(forKey: DefaultKeys.authKey.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    private class func saveValue(_ value: Any? ,_ key:DefaultKeys){
        var data: Data?
        if let value = value{
//            data = NSKeyedArchiver.archivedData(withRootObject: value)
            data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
        }
        UserDefaults.standard.set(data, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    
 
    
    private class func saveUserDetails<T: Codable>(_ value: T?, _ key: DefaultKeys){
        var data: Data?
        if let value = value{
            data = try? PropertyListEncoder().encode(value)
        }
        Store.saveValue(data, key)
    }
    
    private class func getUserDetails<T: Codable>(_ key: DefaultKeys) -> T?{
        if let data = self.getValue(key) as? Data{
            let loginModel = try? PropertyListDecoder().decode(T.self, from: data)
            return loginModel
        }
        return nil
    }
    
    private class func getValue(_ key: DefaultKeys) -> Any{
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data{
            if let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            {
                return value
            }
            else{
                return ""
            }
        }else{
            return ""
        }
    }
}
