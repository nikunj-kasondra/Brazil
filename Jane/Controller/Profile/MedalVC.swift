//
//  MedalVC.swift
//  Jane
//
//  Created by Rujal on 6/5/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class MedalVC: UIViewController {

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tblMedal: UITableView!
    var medalArr = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = ((AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userName") as! String) + "'s Conquests"
        tblMedal.register(UINib(nibName: "MedalCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblMedal.rowHeight = UITableViewAutomaticDimension
        tblMedal.estimatedRowHeight = 44
        tblMedal.separatorStyle = .none
        callMedal()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    func callMedal() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.medals
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
                    self.medalArr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    print(self.medalArr)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.tblMedal.reloadData()
                }
            }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
}
extension MedalVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medalArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! MedalCell
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (self.medalArr.value(forKey: "image") as! NSArray).object(at: indexPath.row) as! String)
        
        
        cell.imgMedal.kf.indicatorType = .activity
        cell.imgMedal.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                
            } else {
                // handle the failure
                print(error)
            }
        }
        
        cell.lblName.text = ((self.medalArr.value(forKey: "title") as! NSArray).object(at: indexPath.row) as! String)
        cell.lblDesc.text = ((self.medalArr.value(forKey: "description") as! NSArray).object(at: indexPath.row) as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
