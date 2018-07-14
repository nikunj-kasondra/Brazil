//
//  PhotoGalleryVC.swift
//  Jane
//
//  Created by Rujal on 6/5/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoGalleryVC: UIViewController {
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var collWidth: NSLayoutConstraint!
    @IBOutlet weak var learnerColl: UICollectionView!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var lblPhoto: UILabel!
    @IBOutlet weak var lblAlbum: UILabel!
    var tab:Int = 0
    var resAll = NSDictionary()
    var resAll1 = NSDictionary()
    var childArr = NSArray()
    var allPhoto = NSArray()
    var albumPhoto = NSMutableArray()
    var tmpAlbumPhoto = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAlbum.isHidden = true
        collView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "newCell")
        collView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "photo")
        learnerColl.register(UINib(nibName: "learnerCell", bundle: nil), forCellWithReuseIdentifier: "learnerCell")
        callAllPhoto()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            teacherView.isHidden = false
            studentView.isHidden = true
            SideMenuView1.btnIndex = 3
            SideMenuView1.add(toVC: self, toView: self.view)
        }
        else {
            SideMenuView.btnIndex = 5
            SideMenuView.add(toVC: self, toView: self.view)
            
            teacherView.isHidden = true
            studentView.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func callAllPhoto() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.allPhoto
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    if let dict =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
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
                    }
                    self.resAll1 = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    self.allPhoto = self.resAll1.value(forKey: "photos") as! NSArray
                    Progress.hide(toView: self.view)
                    self.callGallery()
                } catch _ {
                    self.callGallery()
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.collView.reloadData()
                }
                }.resume()
        } else {
            
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    func callGallery() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.albums
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    if let dict =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
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
                    }
                    self.resAll = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    self.childArr = (self.resAll.value(forKey: "learnersFilter") as! NSArray)
                    self.albumPhoto = (self.resAll.value(forKey: "albums") as! NSArray).mutableCopy() as! NSMutableArray
                    self.tmpAlbumPhoto.removeAllObjects()
                    self.tmpAlbumPhoto = (self.resAll.value(forKey: "albums") as! NSArray).mutableCopy() as! NSMutableArray
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    //self.collView.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    @IBAction func btnAlbumClicked(_ sender: Any) {
        lblAlbum.isHidden = false
        lblPhoto.isHidden = true
        tab = 1
        DispatchQueue.main.async {
            self.collView.reloadData()
        }
    }
    
    @IBAction func btnPhotoClicked(_ sender: Any) {
        lblAlbum.isHidden = true
        lblPhoto.isHidden = false
        tab = 0
        DispatchQueue.main.async {
            self.collView.reloadData()
        }
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            if !SideMenuView1.isOpen {
                
                SideMenuView1.open(toView: self.view)
                
            } else {
                
                SideMenuView1.close(toView: self.view)
                
            }
        }
        else {
            if !SideMenuView.isOpen {
                
                SideMenuView.open(toView: self.view)
                
            } else {
                
                SideMenuView.close(toView: self.view)
                
            }
        }
    }
    func convertDateFormate(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM yyyy"
        let newDate = dateFormate.string(from: date)
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return day + " " + newDate
    }
    @IBAction func btnClockClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "RoutineVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnAgendaClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AgendaVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    
    @IBAction func btnChatClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnNewsClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    
    @IBAction func btnAttendanceClcked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceList")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
}
extension PhotoGalleryVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == learnerColl {
            if 45 * childArr.count > 200 {
                collWidth.constant = 200
            } else {
                collWidth.constant = CGFloat(45 * childArr.count)
            }
            return childArr.count
        }
        else if tab == 0 {
            return self.allPhoto.count
        } else {
            return self.tmpAlbumPhoto.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == learnerColl {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnerCell", for: indexPath) as! learnerCell
            let dict = childArr.object(at: indexPath.row) as! NSDictionary
            cell.lblCount.text = String(describing:(dict.value(forKey: "howMany") as! NSNumber))
            let tmpStr = (dict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
            cell.lblCount.textColor = UIColor.init(hexString: "#" + String(tmpStr))
            cell.learnerImg.borderColor1 = UIColor.init(hexString: "#" + String(tmpStr))
            
            //cell.lblCount.text = 
            let modifier = AnyModifier { request in
                var r = request
                // replace "Access-Token" with the field name you need, it's just an example
                r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
                return r
            }
            
            let url = URL(string: (dict.value(forKey: "image") as! String))
            
            
            
            cell.learnerImg.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
                if error == nil && image != nil {
                    // here the downloaded image is cached, now you need to set it to the imageView
                    
                } else {
                    // handle the failure
                    print(error)
                }
            }
            print(dict)
            return cell
        }
        else if tab == 0 {
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoCell
            let modifier = AnyModifier { request in
                var r = request
                // replace "Access-Token" with the field name you need, it's just an example
                r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
                return r
            }
            let dict = self.allPhoto.object(at: indexPath.row) as! NSDictionary
            
            let url = URL(string: (dict.value(forKey: "thumbnailImage") as! String))
            
            cell1.imgPhoto.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
                if error == nil && image != nil {
                    // here the downloaded image is cached, now you need to set it to the imageView
                    
                } else {
                    // handle the failure
                    print(error)
                }
            }
            return cell1
        } else {
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as! AlbumCell
            let modifier = AnyModifier { request in
                var r = request
                // replace "Access-Token" with the field name you need, it's just an example
                r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
                return r
            }
            let dict = self.tmpAlbumPhoto.object(at: indexPath.row) as! NSDictionary
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyyMMdd"
            let date = dateFormat.date(from: dict.value(forKey: "date") as! String)
            cell2.lblDate.text = convertDateFormate(date: date!)
            cell2.lblAlbumName.text = dict.value(forKey: "name") as! String
            cell2.lblCount.text = String(describing:(dict.value(forKey: "numberOfPhotos") as! NSNumber)) + " Photos"
            let url = URL(string: (dict.value(forKey: "coverImage") as! String))
            
            cell2.imgPhoto.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
                if error == nil && image != nil {
                    // here the downloaded image is cached, now you need to set it to the imageView
                    
                } else {
                    // handle the failure
                    print(error)
                }
            }
            return cell2
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == learnerColl {
            return CGSize(width: 45, height: 45)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.width / 2)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == learnerColl && tab == 1{
            self.tmpAlbumPhoto.removeAllObjects()
            let dict = childArr.object(at: indexPath.row) as! NSDictionary
            
            for i in 0..<self.albumPhoto.count {
                let dict1 = albumPhoto.object(at: i) as! NSDictionary
                let tmpArr = dict1.value(forKey: "learnersHashes") as! NSArray
                for j in 0..<tmpArr.count {
                    if dict.value(forKey: "learnerHash") as! String == tmpArr.object(at: j) as! String {
                        self.tmpAlbumPhoto.add(self.albumPhoto.object(at: i) as! NSDictionary)
                    }
                }
                
            }
            DispatchQueue.main.async {
                self.collView.reloadData()
            }
        } else {
            if tab == 1 {
                let dict = self.tmpAlbumPhoto.object(at: indexPath.row) as! NSDictionary
                GalleryPhoto.hashValue = dict.value(forKey: "albumHash") as! String
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "GalleryPhoto")
                Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
            } else {
                
                GalleryPhoto.hashValue = self.resAll1.value(forKey: "albumHash") as! String
                let dict = self.allPhoto.object(at: indexPath.row) as! NSDictionary
                PhotoDetailVC.photoHash = dict.value(forKey: "photoHash") as! String
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailVC")
                Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
            }
        }
    }
}
