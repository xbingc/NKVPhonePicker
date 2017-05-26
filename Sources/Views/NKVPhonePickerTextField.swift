//
// Be happy and free :)
//
// Nik Kov
// nik-kov.com
//

import UIKit

public class NKVPhonePickerTextField: UITextField {
    // MARK: - Interface
    /// Set this property in order to present the CountryPickerViewController
    /// when user clicks on the flag button
    @IBOutlet weak var phonePickerDelegate: UIViewController?

    /// - Returns: Current phone number in textField with spaces. Ex: +7 999 777 33 44
    public var rawPhoneNumber: String {
        return self.text ?? ""
    }
    
    /// - Returns: Current phone number in textField without '+'. Ex: +79997773344.
    public var phoneNumber: String {
        return self.text?.cutSpaces.cutPluses ?? ""
    }
    
    /// - Returns: Current phone number in textField without code. Ex: 9997773344.
    public var phoneNumberWithoutCode: String {
        if isPlusPrefixImmortal {
            return (self.text?.stringByReplacingOccurrencesOfString("+\(code)", withString: "").cutSpaces.cutPluses)!
        } else {
            return "This feature is not available yet with 'isPlusPrefixImmortal == false'"
        }
    }
    
    /// - Returns: Current phone code without +. Ex: 7
    public var code: String {
        return flagView.currentPresentingCountry.phoneExtension.cutPluses 
    }
    
    // Country picker customization properties:
    public var pickerTitle: String?
    public var pickerTitleFont: UIFont?
    public var pickerCancelButtonTitle: String?
    public var pickerCancelButtonColor: UIColor?
    public var pickerCancelButtonFont: UIFont?
    public var pickerBarTintColor: UIColor?
    
    /// Insets for the flag icon.
    ///
    /// Left and right insets affect on flag view. 
    /// Top and bottom insets - on image only.
    public var flagInsets: UIEdgeInsets? { didSet { customizeSelf() } }
    public var flagSize: CGSize?         { didSet { customizeSelf() } }
    
    /// The UIView subclass which contains flag icon. 
    var flagView: NKVFlagView!
    
    /// This var returnes an entity of current selected country.
    public var currentSelectedCountry: Country? {
        didSet {
            if let selected = currentSelectedCountry {
                self.setCode(selected)
                self.setFlagWithCountry(selected)
            }
        }
    }
    
    /// Use this var for setting countries in the top of the tableView
    /// Ex:
    ///
    ///     countryVC.favoriteCountriesLocaleIdentifiers = ["RU", "JM", "GB"]   
    public var favoriteCountriesLocaleIdentifiers: [String]?
    
    /// Set to 'false' if you want to make available to erase the plus character
    /// while editing the textField.
    public var isPlusPrefixImmortal: Bool = true
    
    /// Show is there a valid country flag (not with question mark).
    public var isFlagExist: Bool = false
    
    /// Set to 'false' if you don't need to scroll to selected country in CountryPickerViewController.
    public var shouldScrollToSelectedCountry: Bool = true
    
    /// Method for set code in textField with Country entity.
    public func setCode(country: Country) {
        self.text = "+\(country.phoneExtension) "
    }
    
    /// Method for set flag with countryCode.
    ///
    /// If nil it would be "?" code. This code present a flag with question mark.
    public func setFlagWithCountryCode(countryCode: String?) {
        flagView.setFlagWithCountryCode(countryCode)
    }
    
    /// Method for set flag with Country entity.
    public func setFlagWithCountry(country: Country) {
        flagView.setFlagWithCountry(country)
    }
    
    /// Method for set flag with phone extenion.
    public func setFlagWithPhoneExtension(phoneExtension: String) {
        if NKVSourcesHelper.isFlagExistsWith(phoneExtension) {
            flagView.setFlagWithPhoneExtension(phoneExtension)
        }
    }
    
    // MARK: - Implementation
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.leftViewMode = .Always;
        self.keyboardType = .NumberPad
        flagView = NKVFlagView(with: self)
        self.leftView = flagView
        self.delegate = self
        
        currentSelectedCountry = Country.currentCountry
        
        flagView.flagButton.addTarget(self, action: #selector(presentCountriesViewController), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: .EditingChanged)
    }
    
    /// Presents a view controller to choose a country code.
    @objc private func presentCountriesViewController() {
        if let delegate = phonePickerDelegate {
            let countriesVC = CountriesViewController.standardController()
            countriesVC.delegate = self as CountriesViewControllerDelegate
            let navC = UINavigationController.init(rootViewController: countriesVC)
            
            customizeCountryPicker(countriesVC)
            delegate.presentViewController(navC, animated: true, completion: nil)
        }
    }
    
    // MARK: Customization
    /// Method to customize the CountryPickerController.
    private func customizeCountryPicker(pickerVC: CountriesViewController) {
        pickerVC.shouldScrollToSelectedCountry = shouldScrollToSelectedCountry
        
        if let currentSelectedCountry = currentSelectedCountry {
            pickerVC.selectedCountry = currentSelectedCountry
        }
        if let favoriteCountriesLocaleIdentifiers = favoriteCountriesLocaleIdentifiers {
            pickerVC.favoriteCountriesLocaleIdentifiers = favoriteCountriesLocaleIdentifiers
        }
        if let pickerTitle = pickerTitle {
            pickerVC.countriesVCNavigationItem.title = pickerTitle
        }
        if let pickerTitleFont = pickerTitleFont, let navController = pickerVC.navigationController {
            let fontAttributes = [NSFontAttributeName: pickerTitleFont]
            navController.navigationBar.titleTextAttributes = fontAttributes
        }
        if let pickerCancelButtonFont = pickerCancelButtonFont {
            let fontAttributes = [NSFontAttributeName: pickerCancelButtonFont]
            pickerVC.countriesVCNavigationItem.leftBarButtonItem?.setTitleTextAttributes(fontAttributes, forState: .Normal)
            pickerVC.countriesVCNavigationItem.leftBarButtonItem?.setTitleTextAttributes(fontAttributes, forState: .Highlighted)
        }
        if let pickerCancelButtonTitle = pickerCancelButtonTitle {
            pickerVC.countriesVCNavigationItem.leftBarButtonItem?.title = pickerCancelButtonTitle
        }
        if let pickerCancelButtonColor = pickerCancelButtonColor {
            pickerVC.countriesVCNavigationItem.leftBarButtonItem?.tintColor = pickerCancelButtonColor
        }
        if let pickerBarTintColor = pickerBarTintColor, let navController = pickerVC.navigationController {
            navController.navigationBar.barTintColor = pickerBarTintColor
        }
    }
    
    private func customizeSelf() {
        if let flagInsets = flagInsets {
            flagView.insets = flagInsets
        }
        if let flagSize = flagSize {
            flagView.iconSize = flagSize
        }
    }
}

extension NKVPhonePickerTextField: CountriesViewControllerDelegate {
    public func countriesViewController(sender: CountriesViewController, didSelectCountry country: Country) {
        currentSelectedCountry = country
    }
    public func countriesViewControllerDidCancel(sender: CountriesViewController) {
        /// Do nothing yet
    }
}

extension NKVPhonePickerTextField: UITextFieldDelegate {
    
    @objc func textFieldDidChange() {
        if let newString = self.text {
            if newString.characters.count == 1 || newString.characters.count == 0 {
                self.setFlagWithCountryCode("?")
            }
            
            if isPlusPrefixImmortal {
                self.text = "+\(newString.cutPluses)"
            }

            self.setFlagWithPhoneExtension(newString)
        }
    }
}
