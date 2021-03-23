//
//  UIDevice+ModelName.swift
//  Keys
//
//

import Foundation
import UIKit

public extension UIDevice {


    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }


    var modelNameCase: (name: String, case: String) {
        return UIDevice.modelNameCase(identifier: modelIdentifier)
    }

    static func modelNameCase(identifier: String) -> (name: String, case: String) {

        switch identifier {
        case "iPod5,1":                                 return ("iPod Touch 5", "iPhone-home")
        case "iPod7,1":                                 return ("iPod Touch 6", "iPhone-home")
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return ("iPhone 4", "iPhone-home")
        case "iPhone4,1":                               return ("iPhone 4s", "iPhone-home")
        case "iPhone5,1", "iPhone5,2":                  return ("iPhone 5", "iPhone-home")
        case "iPhone5,3", "iPhone5,4":                  return ("iPhone 5c", "iPhone-home")
        case "iPhone6,1", "iPhone6,2":                  return ("iPhone 5s", "iPhone-home")
        case "iPhone7,2":                               return ("iPhone 6", "iPhone-home")
        case "iPhone7,1":                               return ("iPhone 6 Plus", "iPhone-home")
        case "iPhone8,1":                               return ("iPhone 6s", "iPhone-home")
        case "iPhone8,2":                               return ("iPhone 6s Plus", "iPhone-home")
        case "iPhone9,1", "iPhone9,3":                  return ("iPhone 7", "iPhone-home")
        case "iPhone9,2", "iPhone9,4":                  return ("iPhone 7 Plus", "iPhone-home")
        case "iPhone8,4":                               return ("iPhone SE", "iPhone-home")
        case "iPhone10,1", "iPhone10,4":                return ("iPhone 8", "iPhone-home")
        case "iPhone10,2", "iPhone10,5":                return ("iPhone 8 Plus", "iPhone-home")
        case "iPhone10,3", "iPhone10,6":                return ("iPhone X", "iPhone-notch")
        case "iPhone11,2":                              return ("iPhone XS", "iPhone-notch")
        case "iPhone11,4","iPhone11,6":                 return ("iPhone XS Max", "iPhone-notch")
        case "iPhone11,8":                              return ("iPhone XR", "iPhone-notch")
        case "iPhone12,1":                              return ("iPhone 11", "iPhone-notch")
        case "iPhone12,3":                              return ("iPhone 11 Pro", "iPhone-notch")
        case "iPhone12,5":                              return ("iPhone 11 Pro Max", "iPhone-notch")

        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return ("iPad 2", "iPad-home")
        case "iPad3,1", "iPad3,2", "iPad3,3":           return ("iPad 3", "iPad-home")
        case "iPad3,4", "iPad3,5", "iPad3,6":           return ("iPad 4", "iPad-home")
        case "iPad4,1", "iPad4,2", "iPad4,3":           return ("iPad Air", "iPad-home")
        case "iPad5,3", "iPad5,4":                      return ("iPad Air 2", "iPad-home")
        case "iPad6,11", "iPad6,12":                    return ("iPad 5", "iPad-home")
        case "iPad7,5", "iPad7,6":                      return ("iPad 6", "iPad-home")
        case "iPad2,5", "iPad2,6", "iPad2,7":           return ("iPad Mini", "iPad-home")
        case "iPad4,4", "iPad4,5", "iPad4,6":           return ("iPad Mini 2", "iPad-home")
        case "iPad4,7", "iPad4,8", "iPad4,9":           return ("iPad Mini 3", "iPad-home")
        case "iPad5,1", "iPad5,2":                      return ("iPad Mini 4", "iPad-home")
        case "iPad6,3", "iPad6,4":                      return ("iPad Pro", "iPad-home")
        case "iPad6,7", "iPad6,8":                      return ("iPad Pro", "iPad-home")
        case "iPad7,1", "iPad7,2":                      return ("iPad Pro", "iPad-home")
        case "iPad7,3", "iPad7,4":                      return ("iPad Pro", "iPad-home")
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return ("iPad Pro", "iPad-swipe")
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return ("iPad Pro", "iPad-swipe")
        case "iPad11,1", "iPad11,2":                    return ("iPad Mini", "iPad-swipe")
        case "iPad11,3", "iPad11,4":                    return ("iPad Air", "iPad-swipe")

        case "AppleTV5,3":                              return ("Apple TV", "")
        case "AppleTV6,2":                              return ("Apple TV 4K", "")
        case "AudioAccessory1,1":                       return ("HomePod", "")
        case "i386", "x86_64":                          return ("Simulator", "")

        default:
            if identifier.prefix(6) == "iPhone" {
                return ("iPhone","iPhone-notch")
            } else if identifier.prefix(4) == "iPad" {
                return ("iPad", "iPad-swipe")
            } else {
                return ("","")
            }
        }
    }
    
}
