//
//  PlaceVC.swift
//  Jane
//
//  Created by Rujal on 7/2/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

import MapKit
import GooglePlacesSearchController

class PlaceVC: UIViewController {
    let GoogleMapsAPIServerKey = "YOUR_KEY"
    
    lazy var placesSearchController: GooglePlacesSearchController = {
        let controller = GooglePlacesSearchController(delegate: self,apiKey: "AIzaSyBxQjEtFcghCka1DepT5Jx_aC5FIrtmhrk",placeType: .address
            // Optional: coordinate: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
            // Optional: radius: 10,
            // Optional: strictBounds: true,
            // Optional: searchBarPlaceholder: "Start typing..."
        )
        //Optional: controller.searchBar.isTranslucent = false
        //Optional: controller.searchBar.barStyle = .black
        //Optional: controller.searchBar.tintColor = .white
        //Optional: controller.searchBar.barTintColor = .black
        return controller
    }()
    
    @IBAction func searchAddress(_ sender: UIBarButtonItem) {
        present(placesSearchController, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        Common.navigationController.navigationBar.isHidden = true
    }
    
    @IBAction func btnCancelSearch(_ sender: Any) {
        EditProfileVC.isAddress = false
        EditProfileVC.address = ""
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlaceVC: GooglePlacesAutocompleteViewControllerDelegate {
    func viewController(didAutocompleteWith place: PlaceDetails) {
        print(place.description)
        placesSearchController.isActive = false
        EditProfileVC.isAddress = true
        EditProfileVC.address = place.formattedAddress
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension PlaceVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel")
    }
}
