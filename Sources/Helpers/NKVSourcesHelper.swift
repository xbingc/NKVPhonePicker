//
//  NKVSourcesHelper.swift
//  NKVPhonePicker
//
//  Created by Nik Kov on 24.05.17.
//  Copyright © 2017 nik.kov. All rights reserved.
//

import UIKit

public struct NKVSourcesHelper {
    /// Returns the flag image or nil, if there are not such image for this code.
    public static func getFlagImage(by code: String) -> UIImage? {
        let flagImage = UIImage(named: "Countries.bundle/Images/\(code.uppercaseString)", inBundle: NSBundle(forClass: NKVPhonePickerTextField.self), compatibleWithTraitCollection: nil)
        
        return flagImage
    }
    
    public static func isFlagExistsFor(countryCode: String) -> Bool {
        return (self.getFlagImage(by: countryCode) != nil)
    }
    
    public static func isFlagExistsWith(phoneExtension: String) -> Bool {
        let countryWithString = Country.countryByPhoneExtension(phoneExtension)
        if countryWithString.isEqual(Country.empty) { return false }
        return (self.getFlagImage(by: countryWithString.countryCode) != nil)
    }
    
    public private(set) static var countries: [Country] = {
        var countries: [Country] = []
        
        do {
            if let file = NSBundle(forClass: NKVPhonePickerTextField.self).URLForResource("Countries.bundle/Data/countryCodes", withExtension: "json") {
                let data = NSData(contentsOfURL: file)
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if let array = json as? Array<[String: String]> {
                    for object in array {
                        guard let code = object["code"],
                            let phoneExtension = object["dial_code"] else {
                            fatalError("Must be valid json.")
                        }
                        countries.append(Country(countryCode: code,
                                                 phoneExtension: phoneExtension))
                    }
                }
            } else {
                print("NKVPhonePickerTextField can't find a bundle for the countries")
            }
        } catch {
            print(error)
        }
        
        return countries
    }()
}
