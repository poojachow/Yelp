//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Pooja Chowdhary on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var business: Business!

    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = business.name
        distanceLabel.text = business.distance
        reviewsLabel.text = "\(business.reviewCount!) Reviews"
        addressLabel.text = business.address
        categoriesLabel.text = business.categories
        if let imageURLpresent = business.imageURL {
            thumbImageView.setImageWith(business.imageURL!)
        }
        ratingsImageView.setImageWith(business.ratingImageURL!)
        if business.latitude != nil && business.longitude != nil {
            let latitude = business.latitude
            let longitude = business.longitude
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 25
            locationManager.requestWhenInUseAuthorization()
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(coordinates, span)
            mapView.setRegion(region, animated: false)

            let businessLocation = CLLocation(latitude: business.latitude!, longitude: business.longitude!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = businessLocation.coordinate
            annotation.title = business.name
            self.mapView.addAnnotation(annotation)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
