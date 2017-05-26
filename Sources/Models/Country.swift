//
//  Country.swift
//  PhoneNumberPicker
//
//  Created by Hugh Bellamy on 06/09/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

import Foundation

public class Country: NSObject {
    /// Ex: "RU"
    public var countryCode: String
    /// Ex: "+7"
    public var phoneExtension: String
    @objc public var name: String {
        return NKVLocalizationHelper.countryName(by: countryCode) ?? ""
    }

    public init(countryCode: String, phoneExtension: String) {
        self.countryCode = countryCode
        self.phoneExtension = phoneExtension
    }
    
    /// Returns a Country entity of the current iphone's localization region code
    /// or empty country if it not exist.
    public static var currentCountry: Country {
        guard let currentCountryCode = NKVLocalizationHelper.currentCode else {
            return Country.empty
        }
        return Country.countryByCountryCode(currentCountryCode)
    }
    
    /// Making entities comparable
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? Country {
            return countryCode == rhs.countryCode
        }
        return false
    }
    
    // MARK: - Class methods   
    
    /// Returnes an empty country entity for test or other purposes. 
    /// "+" code returns a flag with question mark.
    public static var empty: Country {
        return Country(countryCode: "?", phoneExtension: "")
    }
    
    /// Returns a country by a phone extension.
    ///
    /// - Parameter phoneExtension: For example: "+241"
    public class func countryByPhoneExtension(phoneExtension: String) -> Country {
        let phoneExtension = phoneExtension.cutPluses
        for country in NKVSourcesHelper.countries {
            if phoneExtension == country.phoneExtension {
                return country
            }
        }
        return Country.empty
    }
    
    /// Returns a country by a country code.
    ///
    /// - Parameter countryCode: For example: "FR"
    public class func countryByCountryCode(countryCode: String) -> Country {
        for country in NKVSourcesHelper.countries {
            if countryCode.lowercaseString == country.countryCode.lowercaseString {
                return country
            }
        }
        return Country.empty
    }
    
    /// Returns a countries array from the country codes.
    ///
    /// - Parameter countryCodes: For example: ["FR", "EN"]
    public class func countriesByCountryCodes(countryCodes: [String]) -> [Country] {
        return countryCodes.map { code in
            Country.countryByCountryCode(code)
        }
    }
}
