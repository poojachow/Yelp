//
//  FilterViewController.swift
//  Yelp
//
//  Created by Pooja Chowdhary on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    @objc optional func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: [String:AnyObject])
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterCellDelegate {
    var visibleList = [[String: AnyObject]()]
    var selectedList = [[String: AnyObject]()]
    var displayList = [[String: AnyObject]()]
    var isExpanded = [Bool]()
    
    var categories: [[String:String]]!
    var sortList: [[String: String]]!
    var dealList: [[String: String]]!
    var distanceList: [[String: String]]!
    
    var categorySwitchStates = [Int:Bool]()
    var sortSwitchStates = [Int:Bool]()
    var dealSwitchStates = [Int:Bool]()
    var distanceSwitchStates = [Int:Bool]()
    
    weak var delegate: FilterViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: UIBarButtonItem) {
        var filters = [String:AnyObject]()
        //selected categories returned to BusinessViewController
        var selectedCategories = [String]()
        for (row, isSelected) in categorySwitchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        //selected sort returned to BusinessViewController
        var selectedSort: YelpSortMode!
        for (_, isSelected) in selectedList[1] {
            let temp = isSelected[0] as? [String:String]
            for (key, value) in temp! {
                if key == "code" {
                    selectedSort = YelpSortMode(rawValue: Int(value)!)
                }
            }
        }
        if selectedSort != nil {
            filters["sort"] = selectedSort as AnyObject?
        }
        //selected deal returned to BusinessViewController
        var selectedDeal: Bool!
        for (_, isSelected) in dealSwitchStates {
            selectedDeal = isSelected
        }
        if selectedDeal != nil {
            filters["deals"] = selectedDeal as AnyObject?
        }
        //selected distance returned to BusinessViewController
        var selectedDistance: Double!
        for (_, isSelected) in selectedList[2] {
            let temp = isSelected[0] as? [String:String]
            for (key, value) in temp! {
                if key == "code" {
                    selectedDistance = Double(value) ?? nil
                }
            }
        }
        if selectedDistance != nil {
            filters["distance"] = selectedDistance as AnyObject?
        }
        
        delegate?.filterViewController?(filterViewController: self, didUpdateFilters: filters)
         dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        categories = yelpCategories()
        sortList = yelpSort()
        dealList = yelpDeal()
        distanceList = yelpDistance()
        
        var tempObj = ["Deals" : (dealList as AnyObject?)!]
        displayList[0] = tempObj as [String : AnyObject]
        visibleList[0] = tempObj as [String : AnyObject]
        
        tempObj = ["Sort By" : sortList as AnyObject]
        displayList.append(tempObj as [String : AnyObject])
        var sortItem = [[String:String]]()
        sortItem.append(sortList[0])
        let sortVisible = ["Sort By" : sortItem as AnyObject]
        visibleList.append(sortVisible as [String : AnyObject])
        
        tempObj = ["Distance" : distanceList as AnyObject]
        displayList.append(tempObj as [String : AnyObject])
        var distanceItem = [[String:String]]()
        distanceItem.append(distanceList[0])
        let distanceVisible = ["Distance" : distanceItem as AnyObject]
        visibleList.append(distanceVisible as [String : AnyObject])
        
        tempObj = ["Categories" : (categories as AnyObject?)!]
        displayList.append(tempObj as [String : AnyObject])
        visibleList.append(tempObj as [String : AnyObject])
        selectedList = visibleList
        for _ in 1...visibleList.count {
            isExpanded.append(false)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
    //    return displayList.count
        return visibleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    let currentSection = displayList[section]
        let currentSection = visibleList[section]
        if currentSection.count > 0 {
            for (key, value) in currentSection {
                return value.count as Int
            }
            print("Entered in if statement of numberOfSections")
            return 0
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //let currentSection = displayList[section]
        let currentSection = visibleList[section]
        if currentSection.count > 0 {
            for (key, _) in currentSection {
                return key
            }
            print("Entered in if statement of numberOfSections")
        }
        return "Title not mentioned!"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.delegate = self
        
      //  let currentSection = displayList[indexPath.section]
        let currentSection = visibleList[indexPath.section]
        if currentSection.count > 0 {
            for (_, value) in currentSection {
                let temp = value as! [[String:String]]
                cell.nameLabel.text = temp[indexPath.row]["name"]
                switch indexPath.section {
                case 0:
                    cell.onSwitch.isHidden = false
                    cell.onSwitch.isOn = dealSwitchStates[indexPath.row] ?? false
                case 1:
                    cell.onSwitch.isHidden = true
                    cell.onSwitch.isOn = sortSwitchStates[indexPath.row] ?? false
                case 2:
                    cell.onSwitch.isHidden = true
                    cell.onSwitch.isOn = distanceSwitchStates[indexPath.row] ?? false
                case 3:
                    cell.onSwitch.isHidden = false
                    cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false
                default:
                    print("Should not come here! Incorrect section")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 2{
            if isExpanded[indexPath.section] == true {
                isExpanded[indexPath.section] = false
                if indexPath.section == 1 {
                    var sortItem = [[String:String]]()
                    sortItem.append(sortList[indexPath.row])
                    let sortVisible = ["Sort By" : sortItem as AnyObject]
                    selectedList[indexPath.section] = sortVisible
                }
                else {
                    var distanceItem = [[String:String]]()
                    distanceItem.append(distanceList[indexPath.row])
                    let distanceVisible = ["Distance" : distanceItem as AnyObject]
                    selectedList[indexPath.section] = distanceVisible
                }
                visibleList[indexPath.section] = selectedList[indexPath.section]
            }
            else {
                isExpanded[indexPath.section] = true
                visibleList[indexPath.section] = displayList[indexPath.section]
            }
            let indexSet = IndexSet(integer: indexPath.section)
            tableView.reloadSections(indexSet, with: UITableViewRowAnimation.bottom)
        }
    }
    
    func filterCell(filterCell: FilterCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: filterCell)
        switch indexPath?.section {
        case 0?:
            dealSwitchStates[(indexPath?.row)!] = value
        case 1?:
            sortSwitchStates[(indexPath?.row)!] = value
        case 2?:
            distanceSwitchStates[(indexPath?.row)!] = value
        case 3?:
            categorySwitchStates[(indexPath?.row)!] = value
        default:
            print("Incorrect case! in filterCell() in FilterViewController")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func yelpDeal() -> [[String: String]] {
        return [["name" : "Offering a Deal", "code" : ""]]
    }
    
    func yelpSort() -> [[String: String]] {
        return [["name" : "Best Matched", "code" : "0"],
                ["name" : "Distance", "code" : "1"],
                ["name" : "Highest Rated", "code" : "2"]]
    }
    
    func yelpDistance() -> [[String: String]] {
        return [["name" : "Best Match", "code" : "nil"],
                ["name" : "0.3 miles", "code" : "0.3"],
                ["name" : "1 mile", "code" : "1"],
                ["name" : "5 miles", "code" : "5"],
                ["name" : "20 miles", "code" : "20"]]
    }

    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }

}
