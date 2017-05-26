//
// Be happy and free :)
//
// Nik Kov
// nik-kov.com
//

import UIKit

final public class NKVFlagView: UIView {
    // MARK: - Interface
    /// Size of the flag icon
    public var iconSize: CGSize     { didSet { configureInstance() } }
    /// Shifting for the icon from top, left, bottom and right.
    public var insets: UIEdgeInsets { didSet { configureInstance() } }
    
    /// Shows what country is presenting now.
    public var currentPresentingCountry: Country = Country.empty
    
    public var flagButton: UIButton = UIButton()
    
    /// Convenience method to set the flag with Country entity.
    public func setFlagWithCountry(country: Country) {
        self.setFlagWithCountryCode(country.countryCode)
    }
    
    /// Convenience method to set the flag with phone extension.
    public func setFlagWithPhoneExtension(phoneExtension: String) {
        let country = Country.countryByPhoneExtension(phoneExtension)
        self.setFlagWithCountry(country)
    }
    
    /// Method for setting a flag with country (region) code.
    public func setFlagWithCountryCode(countryCode: String?) {
        let code = countryCode ?? "?"
        
        currentPresentingCountry = Country.countryByCountryCode(code)
        
        let flagImage = NKVSourcesHelper.getFlagImage(by: code)
        self.flagButton.setImage(flagImage, forState: .Normal)
        self.flagButton.imageView?.contentMode = .ScaleAspectFit
    }
    
    public required init(with textField: UITextField) {
        self.textField = textField
        self.insets = UIEdgeInsetsMake(7, 7, 7, 7)
        self.iconSize = CGSize(width: 18.0, height: textField.frame.height)
        super.init(frame: CGRect.zero)
        configureInstance()
        setFlagWithCountryCode(NKVLocalizationHelper.currentCode)
    }
    
    // MARK: - Implementation
    private weak var textField: UITextField!

    private func configureInstance() {
        // Setting flag view's frame
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: insets.left + insets.right + iconSize.width,
                            height: max(textField.frame.height, iconSize.height))
        
        // Adding flag button to flag's view
        flagButton = UIButton.init(frame: self.frame)
        flagButton.imageEdgeInsets = insets;
        flagButton.contentMode = .ScaleToFill
        if flagButton.superview == nil { self.addSubview(flagButton) }
        
        self.layoutIfNeeded()
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not supported"); }
}
