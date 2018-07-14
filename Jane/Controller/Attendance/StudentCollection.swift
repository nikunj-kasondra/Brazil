//
//  StudentCollection.swift
//  Jane
//
//  Created by Rujal on 6/3/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class StudentCollection: UIViewController {
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblList: UILabel!
    @IBOutlet weak var lblPhoto: UILabel!
    static var attendanceHash = ""
    static var date = ""
    static var className = ""
    var resArr = NSMutableArray()
    var mainResArr = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarHeight.constant = 0
        noView.isHidden = true
        collView.register(UINib(nibName: "StudentCell", bundle: nil), forCellWithReuseIdentifier: "newCell")
        tblList.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "listCell")
        tblList.rowHeight = UITableViewAutomaticDimension
        tblList.estimatedRowHeight = 44
        lblDate.text = StudentCollection.date
        lblClass.text = StudentCollection.className
        callNotification()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        lblList.isHidden = true
        lblPhoto.isHidden = false
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            teacherView.isHidden = false
            studentView.isHidden = true
        }
        else {
            teacherView.isHidden = true
            studentView.isHidden = false
        }
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCalendarClicked(_ sender: Any) {
        DatePickerDialog().show(title:"Choose Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            self.lblDate.text = dateFormatter.string(from: date as Date)
            self.callNotification()
        }
    }
    @IBAction func btnSearchClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            searchBarHeight.constant = 56
        } else {
            searchBarHeight.constant = 0
        }
    }
    func callNotification() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.date(from: self.lblDate.text!)
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date!)
            let reqStr = API.serverURL + "/mobile/gradesInstances/\(StudentCollection.attendanceHash)/attendances?date=\(dateStr)&filter="
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
                    let Arr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    self.resArr = Arr.mutableCopy() as! NSMutableArray
                    self.mainResArr = self.resArr
                    print(self.resArr)
                    DispatchQueue.main.async {
                        self.collView.reloadData()
                    }
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    
    func setAttendance(learnerHash:String,isPresent:Int,index:Int) {
        
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.date(from: self.lblDate.text!)
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date!)
            let reqStr = API.serverURL + "/mobile/gradesInstances/\(StudentCollection.attendanceHash)/attendances?date=\(dateStr)&learnerHash=\(learnerHash)&isPresent=\(isPresent)"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "POST"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if dict.count != 0 {
                        if dict.value(forKey: "wasOK") as! NSNumber == 1 {
                            let dict = (self.resArr.object(at: index) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            if isPresent == 1 {
                                dict["learnerPresent"] = true
                            } else {
                                dict["learnerPresent"] = false
                            }
                            self.resArr.replaceObject(at: index, with: dict)
                            DispatchQueue.main.async {
                                self.collView.reloadData()
                                self.tblList.reloadData()
                            }
                        } else {
                            Alert.show("Jane", message: "Algo deu errado. Por favor, tente novamente.", onVC: self)
                        }
                        
                        
                    } else {
                            Alert.show("Jane", message: "Algo deu errado. Por favor, tente novamente.", onVC: self)
                        }
                    print(dict)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    @IBAction func btnPhotoClicked(_ sender: Any) {
        lblList.isHidden = true
        lblPhoto.isHidden = false
        tblList.isHidden = true
        collView.isHidden = false
        DispatchQueue.main.async {
            self.collView.reloadData()
        }
    }
    @IBAction func btnListClicked(_ sender: Any) {
        lblList.isHidden = false
        lblPhoto.isHidden = true
        tblList.isHidden = false
        collView.isHidden = true
        DispatchQueue.main.async {
            self.tblList.reloadData()
        }
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
extension StudentCollection:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if resArr.count == 0 {
            noView.isHidden = false
        } else {
            noView.isHidden = true
        }
        return self.resArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as! StudentCell
        let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        cell.lblStudentName.text = (dict.value(forKey: "learnerName") as! String)
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (dict.value(forKey: "learnerImage") as! String))
        
        
        cell.imgStudentImage.kf.indicatorType = .activity
        cell.imgStudentImage.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
//                DispatchQueue.main.async {
//                    self.imgProfile.image = image
//                    self.imgSmall.image = image
//                }
            } else {
                // handle the failure
                print(error)
            }
        }
        if (dict.value(forKey: "learnerPresent") as! NSNumber) == 1 {
            cell.imgStudentImage.borderColor1 = UIColor.blue
        } else {
            cell.imgStudentImage.borderColor1 = UIColor.red
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width / 2, height: 160)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            //teacher
            if (dict.value(forKey: "learnerPresent") as! NSNumber) == 1 {
                setAttendance(learnerHash: dict.value(forKey: "learnerHash") as! String, isPresent: 0,index:indexPath.row)
            } else {
                setAttendance(learnerHash: dict.value(forKey: "learnerHash") as! String, isPresent: 1,index:indexPath.row)
            }
        }
        else {
            Alert.show("Jane", message: "Acesso de permissão negado", onVC: self)
        }
        
    }
}
extension StudentCollection:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resArr.count == 0 {
            noView.isHidden = false
        } else {
            noView.isHidden = true
        }
        return self.resArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListCell
        let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        cell.lblStudentName.text = (dict.value(forKey: "learnerName") as! String)
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (dict.value(forKey: "learnerImage") as! String))
        
        
        cell.imgStudentImage.kf.indicatorType = .activity
        cell.imgStudentImage.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                //                DispatchQueue.main.async {
                //                    self.imgProfile.image = image
                //                    self.imgSmall.image = image
                //                }
            } else {
                // handle the failure
                print(error)
            }
        }
        if (dict.value(forKey: "learnerPresent") as! NSNumber) == 1 {
            cell.imgCheck.image = #imageLiteral(resourceName: "Blue_Correct")
        } else {
            cell.imgCheck.image = #imageLiteral(resourceName: "Red_Correct")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            //teacher
            if (dict.value(forKey: "learnerPresent") as! NSNumber) == 1 {
                setAttendance(learnerHash: dict.value(forKey: "learnerHash") as! String, isPresent: 0,index:indexPath.row)
            } else {
                setAttendance(learnerHash: dict.value(forKey: "learnerHash") as! String, isPresent: 1,index:indexPath.row)
            }
        }
        else {
            Alert.show("Jane", message: "Acesso de permissão negado", onVC: self)
        }
        
    }
}
extension StudentCollection:UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resArr = self.mainResArr
        DispatchQueue.main.async {
            self.tblList.reloadData()
            self.collView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.resArr = self.mainResArr
            DispatchQueue.main.async {
                self.tblList.reloadData()
                self.collView.reloadData()
            }
        } else {
            let predicate = NSPredicate(format: "learnerName contains[c] %@",searchText)
            self.resArr = (self.mainResArr.filtered(using: predicate) as NSArray).mutableCopy() as! NSMutableArray
            DispatchQueue.main.async {
                self.tblList.reloadData()
                self.collView.reloadData()
            }
        }
        
    }
}
