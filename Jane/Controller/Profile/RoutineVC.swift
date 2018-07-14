//
//  RoutineVC.swift
//  Jane
//
//  Created by Rujal on 6/7/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class RoutineVC: UIViewController {
    
    
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var imgRoutine: UIImageView!
    @IBOutlet weak var lblType: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStudentName: UILabel!
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var collHeight: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var lblDate1: UILabel!
    @IBOutlet weak var lblProfession: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    var count = 0
    var showRoutine = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.isHidden = true
        collView.register(UINib(nibName: "RoutineCell", bundle: nil), forCellWithReuseIdentifier: "newCell")
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        let dict = AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary
        let url = URL(string: dict.value(forKey: "image") as! String)
       imgProfile.kf.indicatorType = .activity
        imgProfile.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now
            } else {
                // handle the failure
                print(error)
            }
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        self.lblDate.text = dateFormatter.string(from: date)
        callRoutine(date:date)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            SideMenuView1.btnIndex = 4
            SideMenuView1.add(toVC: self, toView: self.view)
            teacherView.isHidden = false
            studentView.isHidden = true
        }
        else {
            SideMenuView.btnIndex = 7
            SideMenuView.add(toVC: self, toView: self.view)
            teacherView.isHidden = true
            studentView.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callRoutine(date:Date) {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let dict = AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date)
            var reqStr = ""
            
            if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
                reqStr = API.routine + "/routine?date=\(dateStr)"
            }
            else {
                reqStr = API.routine + String(((AgendaVC.loginDict.value(forKey: "learners") as! NSArray).value(forKey: "learnerHash") as! NSArray).object(at: 0) as! String) + "/routine?date=\(dateStr)"
            }
            
            //let reqStr = "http://67.205.107.224:6223/jane/mobile/learners/6nEnJZWiSyzuWSAVdrOhJS/routine?date=20180627"
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
                    self.showRoutine.removeAllObjects()
                    if dict.value(forKey: "bath") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Bath","Desc":dict.value(forKey: "bathDescription") as! String,"title1":dict.value(forKey: "bath") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "eat") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Eat","Desc":dict.value(forKey: "eatDescription") as! String,"title1":dict.value(forKey: "eat") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "mood") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Mood","Desc":dict.value(forKey: "moodDescription") as! String,"title1":dict.value(forKey: "mood") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "nursingBottle") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Nursing Bottle","Desc":dict.value(forKey: "nursingBottleDescription") as! String,"title1":dict.value(forKey: "nursingBottle") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "pee") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Pee","Desc":dict.value(forKey: "peeDescription") as! String,"title1":dict.value(forKey: "pee") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "play") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Play","Desc":dict.value(forKey: "playDescription") as! String,"title1":dict.value(forKey: "play") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "poop") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Poop","Desc":dict.value(forKey: "poopDescription") as! String,"title1":dict.value(forKey: "poop") as! String]
                        self.showRoutine.add(dict)
                    }
                    if dict.value(forKey: "sleep") as! String != "DO_NOT_SHOW" {
                        let dict = ["title":"Sleep","Desc":dict.value(forKey: "sleepDescription") as! String,"title1":dict.value(forKey: "sleep") as! String]
                        self.showRoutine.add(dict)
                    }
                    print(dict)
                    if self.showRoutine.count > 4 {
                        self.collHeight.constant = 260
                    } else {
                        self.collHeight.constant = 130
                    }
                    DispatchQueue.main.async {
                        self.lblDesc.text = dict.value(forKey: "description") as! String
                    }
                    
                    Progress.hide(toView: self.view)
                } catch _ {
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
    @IBAction func btnDateClicked(_ sender: Any) {
        DatePickerDialog().show(title:"Choose Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            self.lblDate.text = dateFormatter.string(from: date as Date)
            self.callRoutine(date: date as Date)
            
        }
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
    
    @IBAction func btnOKClicked(_ sender: Any) {
        setRoutine()
        popupView.isHidden = true
    }
    func setRoutine() {
        
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.date(from: self.lblDate.text!)
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date!)
            let dict = AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary
            
            var reqStr = ""
            if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
                reqStr = API.routineAdd + "/routine?date=\(dateStr)"
            }
            else {
                reqStr = API.routineAdd + String(((AgendaVC.loginDict.value(forKey: "learners") as! NSArray).value(forKey: "learnerHash") as! NSArray).object(at: 0) as! String) + "/routine?date=\(dateStr)"
            }
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "POST"
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
                    if dict.count != 0 {
                        if dict.value(forKey: "wasOK") as! NSNumber == 1 {
                            Alert.show("Jane", message: "Rotina enviada com sucesso", onVC: self)
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
    
}
extension RoutineVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showRoutine.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as! RoutineCell
        cell.imgRoutine.image = UIImage(named:(self.showRoutine.value(forKey: "title") as! NSArray).object(at: indexPath.row) as! String)
        cell.lblTitle.text = (self.showRoutine.value(forKey: "title1") as! NSArray).object(at: indexPath.row) as! String
        cell.lblTitle1.text = (self.showRoutine.value(forKey: "title") as! NSArray).object(at: indexPath.row) as! String
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collView.frame.size.width / 4, height: 130)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            popupView.isHidden = false
            
            lblStudentName.text = lblName.text!
            lblDate1.text = "How did \((self.showRoutine.value(forKey: "title") as! NSArray).object(at: indexPath.row) as! String) on \(lblDate.text!)?"
            imgRoutine.image = UIImage(named:(self.showRoutine.value(forKey: "title") as! NSArray).object(at: indexPath.row) as! String)
            lblType.text = (self.showRoutine.value(forKey: "title1") as! NSArray).object(at: indexPath.row) as! String
        }
        else {
            Alert.show("Jane", message: "Acesso de permissão negado", onVC: self)
        }
    }
}
extension RoutineVC:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}

extension RoutineVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
