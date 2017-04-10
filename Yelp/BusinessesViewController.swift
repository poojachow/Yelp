//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate, CLLocationManagerDelegate {
    
    var businesses: [Business]!
    var annotations: [MKAnnotation]!
    var isMoreDataLoading = false
    var searchBar: UISearchBar!
    var searchedString = String()
    var categories: [String]!
    var sort: YelpSortMode!
    var deal: Bool!
    var distance: Double!
    var offset: Int!
    var term: String!
    var latitude: Double!
    var longitude: Double!
    var locationManager: CLLocationManager!
    var isMapViewOn = false //select which view to display = map or table view
    
    @IBOutlet weak var mapOrList: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func mapOrListSelected(_ sender: UIBarButtonItem) {
        if isMapViewOn {
            isMapViewOn = false
            tableView.isHidden = false
            mapView.isHidden = true
            mapOrList.title = "Map"
        }
        else {
            isMapViewOn = true
            tableView.isHidden = true
            mapView.isHidden = false
            mapOrList.title = "List"
            setAnnotationsInMapView()
        }
        doSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        categories = nil
        sort = nil
        deal = nil
        distance = nil
        offset = nil
        term = nil
        latitude = 37.785771
        longitude = -122.406165
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 25
        locationManager.requestWhenInUseAuthorization()
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coordinates, span)
        mapView.setRegion(region, animated: false)
        
        doSearch()
    }
    
    func setAnnotationsInMapView() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        var geocoder = CLGeocoder()

        for business in businesses {
            if business.latitude != nil && business.longitude != nil {
                let businessLocation = CLLocation(latitude: business.latitude!, longitude: business.longitude!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = businessLocation.coordinate
                annotation.title = business.name
                self.mapView.addAnnotation(annotation)
            }
            else {
                geocoder.geocodeAddressString(business.address!, completionHandler: {(placemarks, error) in
                    if let placemarks = placemarks {
                        if placemarks.count != 0 {
                            let coordinate = placemarks.first?.location
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = (coordinate?.coordinate)!
                            annotation.title = business.name
                            self.mapView.addAnnotation(annotation)
                            
                        }
                    }
                })
            }
        }
    }
    

    //Go To Location
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    //Perform search
    fileprivate func doSearch() {
        if !isMapViewOn {
            MBProgressHUD.showAdded(to: self.view, animated: true)
       }
        Business.searchWithTerm(latitude: latitude, longitude: longitude, term: term, sort: sort, categories: categories, deals: deal, distance: distance, offset: offset) { (businesses: [Business]?, error: Error?) in
            self.businesses = businesses
            if !self.isMapViewOn {
                self.tableView.reloadData()
            }
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            if !self.isMapViewOn {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    fileprivate func addToDoSearch() {
        if !isMapViewOn {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        Business.searchWithTerm(latitude: latitude, longitude: longitude, term: term, sort: sort, categories: categories, deals: deal, distance: distance, offset: offset) { (businesses: [Business]?, error: Error?) in
            if let businesses = businesses {
                for business in businesses {
                    self.businesses.append(business)
                    print(business.name!)
                    print(business.address!)
                }
            }
            if !self.isMapViewOn {
                self.tableView.reloadData()
            }
            if !self.isMapViewOn {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        term = nil
        searchBar.resignFirstResponder()
        doSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedString = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        term = searchedString
        doSearch()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging {
                isMoreDataLoading = true
                offset = businesses?.count
                addToDoSearch()
            }            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterSegue" {
            let navigationController = segue.destination as! UINavigationController
            let filterViewController = navigationController.topViewController as! FilterViewController
            filterViewController.delegate = self
        }
        if segue.identifier == "DetailSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let destinationViewController = segue.destination as! BusinessDetailViewController
            destinationViewController.business = businesses[(indexPath?.row)!]
        }
    }
    
    func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: [String : AnyObject]) {
        categories = filters["categories"] as? [String]
        sort = filters["sort"] as? YelpSortMode
        deal = filters["deals"] as? Bool
        distance = filters["distance"] as? Double
        doSearch()
        
        setAnnotationsInMapView()
    }
}
