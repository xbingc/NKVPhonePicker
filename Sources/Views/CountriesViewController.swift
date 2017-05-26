//
// Be happy and free :)
//
// Nik Kov
// nik-kov.com
//

import UIKit

public protocol CountriesViewControllerDelegate {
    func countriesViewControllerDidCancel(sender: CountriesViewController)
    func countriesViewController(sender: CountriesViewController, didSelectCountry country: Country)
}

public final class CountriesViewController: UITableViewController {
    @IBOutlet public weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet public weak var countriesVCNavigationItem: UINavigationItem!
   
    // MARK: - API
    
    /// A class function for retrieving standart controller for picking countries.
    ///
    /// - Returns: Instance of the country picker controller.
    public class func standardController() -> CountriesViewController {
        return UIStoryboard(name: "CountriesViewController", bundle: NSBundle(forClass: NKVPhonePickerTextField.self)).instantiateViewControllerWithIdentifier("CountryPickerVC") as! CountriesViewController
    }
    
    /// Use this var for setting countries in the top of the tableView
    /// Ex:
    ///
    ///     countryVC.favoriteCountriesLocaleIdentifiers = ["RU", "JM", "GB"]
    public var favoriteCountriesLocaleIdentifiers: [String] = []

    /// You can choose to hide or show a cancel button with this property.
    public var isCancelButtonHidden: Bool = false { didSet { configurateCancelButton() } }
    
    /// Set to 'false' if you don't need to scroll to selected country in CountryPickerViewController
    public var shouldScrollToSelectedCountry: Bool = true

    /// A delegate for <CountriesViewControllerDelegate>.
    public var delegate: CountriesViewControllerDelegate?

    /// The current selected country.
    public var selectedCountry: Country?

    override public func viewDidLoad() {
        super.viewDidLoad()
    
        configurateCancelButton()
        setupCountries()
        setupSearchController()
        setupTableView()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    // MARK: - Private
    private var searchController = UISearchController(searchResultsController: nil)
/// An array with which all countries are presenting. This array works with search controller and tableView.
    private var filteredCountries: [[Country]]!
    /// An array with all countries, we have.
    private var unfilteredCountries: [[Country]]! { didSet { filteredCountries = unfilteredCountries } }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        delegate?.countriesViewControllerDidCancel(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setupCountries() {
        unfilteredCountries = partionedArray(NKVSourcesHelper.countries, usingSelector: Selector("name"))
        unfilteredCountries.insert(Country.countriesByCountryCodes(favoriteCountriesLocaleIdentifiers), atIndex: 0)
        tableView.reloadData()
        
        if shouldScrollToSelectedCountry {
            if let selectedCountry = selectedCountry {
                for (index, countries) in unfilteredCountries.enumerate() {
                    if let countryIndex = countries.indexOf(selectedCountry) {
                        let indexPath = NSIndexPath(forRow: countryIndex, inSection: index)
                        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
                        break
                    }
                }
            }
        }
    }

    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.tintColor = UIColor.blackColor()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.extendedLayoutIncludesOpaqueBars = true

        definesPresentationContext = true
    }
    
    private func configurateCancelButton() {
        if let cancelBarButtonItem = cancelBarButtonItem {
            navigationItem.leftBarButtonItem = isCancelButtonHidden ? nil: cancelBarButtonItem
        }
    }
    
    private func setupTableView() {
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexColor = UIColor.blackColor()
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.scrollsToTop = true
    }
    
    private func partionedArray<T: AnyObject>(array: [T], usingSelector selector: Selector) -> [[T]] {
        let collation = UILocalizedIndexedCollation.currentCollation()
        let numberOfSectionTitles = collation.sectionTitles.count
        
        var unsortedSections: [[T]] = Array(count: numberOfSectionTitles, repeatedValue: [])
        for object in array {
            let sectionIndex = collation.sectionForObject(object, collationStringSelector: selector)
            unsortedSections[sectionIndex].append(object)
        }
        
        var sortedSections: [[T]] = []
        for section in unsortedSections {
            let sortedSection = collation.sortedArrayFromArray(section, collationStringSelector: selector) as! [T]
            sortedSections.append(sortedSection)
        }
        return sortedSections
    }
}

// MARK: - TableView Data Source
extension CountriesViewController {
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filteredCountries.count
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return filteredCountries[section].count
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let country = filteredCountries[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = country.name
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.5
        
        cell.detailTextLabel?.text = "+" + country.phoneExtension
        
        let flag = NKVSourcesHelper.getFlagImage(by: country.countryCode)
        cell.imageView?.image = flag
        cell.imageView?.contentMode = .ScaleAspectFit
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 3
        cell.imageView?.transform = CGAffineTransformMakeScale(0.8, 0.8)
        
        cell.accessoryType = .None
        if let selectedCountry = selectedCountry where country.isEqual(selectedCountry) {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    // Sections headers
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let countries = filteredCountries[section]
        if countries.isEmpty {
            return nil
        }
        if section == 0 {
            return ""
        }
        return UILocalizedIndexedCollation.currentCollation().sectionTitles[section - 1]
    }

    // Indexes
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return searchController.active ? nil : UILocalizedIndexedCollation.currentCollation().sectionTitles
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index + 1)
    }
}

// MARK: TableView Delegate
extension CountriesViewController {
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.countriesViewController(self, didSelectCountry: filteredCountries[indexPath.section][indexPath.row])
        if searchController.active { searchController.dismissViewControllerAnimated(true, completion: nil) }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Search
extension CountriesViewController: UISearchControllerDelegate {
    public func willPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.searchBarStyle = .Default
        tableView.reloadSectionIndexTitles()
    }
    public func willDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.searchBarStyle = .Minimal
        tableView.reloadSectionIndexTitles()
    }
}

extension CountriesViewController: UISearchResultsUpdating {
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        searchForText(searchString)
        tableView.reloadData()
    }
    
    private func searchForText(text: String) {
        if text.isEmpty {
            filteredCountries = unfilteredCountries
        } else {
            let allCountriesArray: [Country] = NKVSourcesHelper.countries.filter { $0.name.rangeOfString(text) != nil }
            filteredCountries = partionedArray(allCountriesArray, usingSelector: Selector("name"))
            filteredCountries.insert([], atIndex: 0) //Empty section for our favorites
        }
        tableView.reloadData()
    }
}

extension CountriesViewController: UISearchBarDelegate {
    public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        filteredCountries = unfilteredCountries
                tableView.reloadData()
    }
}
