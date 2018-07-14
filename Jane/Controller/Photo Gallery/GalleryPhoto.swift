//
//  GalleryPhoto.swift
//  Jane
//
//  Created by Rujal on 6/29/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class GalleryPhoto: UIViewController {

    @IBOutlet weak var collGallery: UICollectionView!
    var photoArr = NSArray()
    static var hashValue = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        collGallery.register(UINib(nibName: "PhotoListCell", bundle: nil), forCellWithReuseIdentifier: "newCell")
        callAllPhoto()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func callAllPhoto() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.photoList + "\(GalleryPhoto.hashValue)/photos"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        if let status = dict.value(forKey: "status") as? NSNumber {
                            if status == 403 {
                                Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 500 {
                                Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 400 {
                                Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 406 {
                                Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                            }
                            Progress.hide(toView: self.view)
                            return
                        }
                    self.photoArr = dict.value(forKey: "photos") as! NSArray
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.collGallery.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension GalleryPhoto: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as! PhotoListCell
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        let dict = self.photoArr.object(at: indexPath.row) as! NSDictionary
        
        let url = URL(string: (dict.value(forKey: "thumbnailImage") as! String))
        cell.imgPhoto.kf.indicatorType = .activity
        cell.imgPhoto.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                
            } else {
                // handle the failure
                print(error)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.width / 2)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PhotoDetailVC.photoHash = (self.photoArr.value(forKey: "photoHash") as! NSArray).object(at: indexPath.row) as! String
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
}
