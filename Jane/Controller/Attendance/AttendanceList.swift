//
//  AttendanceList.swift
//  Jane
//
//  Created by Rujal on 6/2/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class AttendanceList: UIViewController {

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noVIew: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tblAttendance: UITableView!
    var resArr = NSArray()
    var mainResArr = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarHeight.constant = 0
        tblAttendance.register(UINib(nibName: "AttendanceListCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblAttendance.rowHeight = UITableViewAutomaticDimension
        tblAttendance.estimatedRowHeight = 44
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateStr = dateFormatter.string(from: date)
        lblDate.text = dateStr
        callNotification()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            teacherView.isHidden = false
            studentView.isHidden = true
        }
        else {
            teacherView.isHidden = true
            studentView.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCalenderClicked(_ sender: Any) {
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
            let dateArr = lblDate.text!.components(separatedBy: " ")
            var year = ""
            if dateArr.count > 2 {
                year = dateArr[2]
            }
            let reqStr = API.gradesInstances + "filter=\(year)"
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
                    
                    self.resArr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    self.mainResArr = self.resArr
                    DispatchQueue.main.async {
                        self.tblAttendance.reloadData()
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

extension AttendanceList: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resArr.count != 0 {
            noVIew.isHidden = true
        } else {
            noVIew.isHidden = false
        }
        return self.resArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! AttendanceListCell
        let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        cell.lblClass.text = (dict.value(forKey: "name") as! String)
        cell.lblAttendance.text = String(describing:(dict.value(forKey: "howManyLearners") as! NSNumber)) + " students"
        cell.lblPerform.text = (dict.value(forKey: "description") as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         StudentCollection.date = lblDate.text!
         let dict = self.resArr.object(at: indexPath.row) as! NSDictionary
        StudentCollection.className = (dict.value(forKey: "name") as! String)
        StudentCollection.attendanceHash = dict.value(forKey: "gradeInstanceHash") as! String
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentCollection")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
    
}
extension AttendanceList:UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         self.resArr = self.mainResArr
        DispatchQueue.main.async {
            self.tblAttendance.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.resArr = self.mainResArr
            DispatchQueue.main.async {
                self.tblAttendance.reloadData()
            }
        } else {
            let predicate = NSPredicate(format: "name contains[c] %@",searchText)
            self.resArr = (self.mainResArr.filtered(using: predicate) as NSArray).mutableCopy() as! NSMutableArray
            DispatchQueue.main.async {
                self.tblAttendance.reloadData()
            }
        }
        
    }
}
