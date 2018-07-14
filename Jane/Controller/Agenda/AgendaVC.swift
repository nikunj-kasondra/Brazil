//
//  AgendaVC.swift
//  Jane
//
//  Created by Rujal on 6/10/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher
import FSCalendar
import Alamofire

class AgendaVC: UIViewController {
    static var loginDict = NSDictionary()
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!

    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var imgStudentColor: UIImageView!
    @IBOutlet weak var lblEventPresent: UILabel!
    @IBOutlet weak var imgEventPresent: UIImageView!
    @IBOutlet weak var lblDescr: UILabel!
    @IBOutlet weak var lblCalDate: UILabel!
    @IBOutlet weak var lblStudentName: UILabel!
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var calendar1: FSCalendar!
    @IBOutlet weak var lblMonth3: UILabel!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var calHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl1Bottom: NSLayoutConstraint!
    @IBOutlet weak var lbl1TOp: NSLayoutConstraint!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var calView: UIView!
    @IBOutlet weak var lblMonth1: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var collWidth: NSLayoutConstraint!
    @IBOutlet weak var learnerColl: UICollectionView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    var resAgenda = NSDictionary()
    var eventDict = NSDictionary()
    var childArr = NSArray()
    var eventArr = NSArray()
    var currentDate = Date()
    var currentDate1 = Date()
    var flag = 0
    var alertDict = NSDictionary()
    let weekName = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let placesData = UserDefaults.standard.object(forKey: "loginResponse") as? NSData
        calView.isHidden = true
        dateView.isHidden = true
        tbl.register(UINib(nibName: "AgendaCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tbl.estimatedRowHeight = 44
        tbl.rowHeight = UITableViewAutomaticDimension
        learnerColl.register(UINib(nibName: "learnerCell", bundle: nil), forCellWithReuseIdentifier: "learnerCell")
        if let placesData = placesData {
            AgendaVC.loginDict = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as! NSDictionary
            print(AgendaVC.loginDict)
        }
        if AppDelegate.isFirst {
            AppDelegate.isFirst = false
            //callPermissionAPI()
        }
        eventView.isHidden = true
        currentDate = Date()
        callAgenda(date: Date())
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.btnMonth.backgroundColor = Common.blueColor
            self.btnDay.backgroundColor = UIColor.white
            self.btnMonth.setTitleColor(UIColor.white, for: .normal)
            self.btnDay.setTitleColor(UIColor.black, for: .normal)
        }
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            SideMenuView1.btnIndex = 0
            SideMenuView1.add(toVC: self, toView: self.view)
            teacherView.isHidden = false
            studentView.isHidden = true
        }
        else {
            SideMenuView.btnIndex = 0
            SideMenuView.add(toVC: self, toView: self.view)
            teacherView.isHidden = true
            studentView.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func btnClockClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "RoutineVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnProfileClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC")
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
    
    @IBAction func btnDayClicked(_ sender: Any) {
        //calView.isHidden = false
        flag = 1
        dateView.isHidden = false
        calView.isHidden = true
        calHeight.constant = 128
        monthView.isHidden = true
        lbl1TOp.constant = 0
        lbl1Bottom.constant = 0
        DispatchQueue.main.async {
            self.lblMonth1.text = ""
            self.btnMonth.backgroundColor = UIColor.white
            self.btnDay.backgroundColor = Common.blueColor
            self.btnMonth.setTitleColor(UIColor.black, for: .normal)
            self.btnDay.setTitleColor(UIColor.white, for: .normal)
            self.lblDate.text = self.convertDateFormate(date: Date())
        }
        self.calendar1.reloadData()
        callDayAgenda(date:currentDate1)
    }
    @IBAction func btnMonthClicked(_ sender: Any) {
        flag = 0
        calView.isHidden = true
        dateView.isHidden = true
        calHeight.constant = 220
        monthView.isHidden = false
        lbl1TOp.constant = 10
        lbl1Bottom.constant = 10
        DispatchQueue.main.async {
            self.btnMonth.backgroundColor = Common.blueColor
            self.btnDay.backgroundColor = UIColor.white
            self.btnMonth.setTitleColor(UIColor.white, for: .normal)
            self.btnDay.setTitleColor(UIColor.black, for: .normal)
        }
        currentDate = Date()
        callAgenda(date: currentDate)
    }
    
    func callAgenda(date:Date) {
        if Reachability.isConnectedToNetwork() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date)
            Progress.show(toView: self.view)
            dateFormatter.dateFormat = "MMMM yyyy"
            lblMonth.text = dateFormatter.string(from: date)
            lblMonth1.text = dateFormatter.string(from: date)
            lbl1TOp.constant = 10
            lbl1Bottom.constant = 10
            let reqStr = API.monthEvents + "date=\(dateStr)"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    self.resAgenda = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let status = self.resAgenda.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 406 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                   print(self.resAgenda)
                    self.childArr = (self.resAgenda.value(forKey: "learners") as! NSArray)
                    self.eventArr = (self.resAgenda.value(forKey: "events") as! NSArray)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    self.tbl.reloadData()
                    self.calendar.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    func callDayAgenda(date:Date) {
        if Reachability.isConnectedToNetwork() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date)
            Progress.show(toView: self.view)
            dateFormatter.dateFormat = "MMMM yyyy"
            //lblMonth.text = dateFormatter.string(from: date)
            lblMonth1.text = ""
            lbl1TOp.constant = 0
            lbl1Bottom.constant = 0
            let reqStr = API.monthEvents + "date=\(dateStr)" + "&isDay=true"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    self.resAgenda = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let status = self.resAgenda.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 406 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                    print(self.resAgenda)
                    self.childArr = (self.resAgenda.value(forKey: "learners") as! NSArray)
                    self.eventArr = (self.resAgenda.value(forKey: "events") as! NSArray)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    self.tbl.reloadData()
                    self.calendar.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    func callAgendaFilter(date:Date,hashValue:String) {
        if Reachability.isConnectedToNetwork() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = dateFormatter.string(from: date)
            Progress.show(toView: self.view)
            dateFormatter.dateFormat = "MMMM yyyy"
            if flag == 0 {
                lblMonth.text = dateFormatter.string(from: date)
                lblMonth1.text = dateFormatter.string(from: date)
                lbl1Bottom.constant = 10
                lbl1TOp.constant = 10
            } else {
                lblMonth.text = ""
                lblMonth1.text = ""
                lbl1Bottom.constant = 0
                lbl1TOp.constant = 0
            }
            let reqStr = API.monthEvents + "date=\(dateStr)" + "&learnersHashes=\(hashValue)"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    self.resAgenda = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let status = self.resAgenda.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        } else if status == 406 {
                            Alert.show("Jane", message: self.resAgenda.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                    print(self.resAgenda)
                    self.childArr = (self.resAgenda.value(forKey: "learners") as! NSArray)
                    self.eventArr = (self.resAgenda.value(forKey: "events") as! NSArray)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    self.tbl.reloadData()
                    self.calendar.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    func callAgendaDetail(hashValue:String) {
        if Reachability.isConnectedToNetwork() {
            
            Progress.show(toView: self.view)
            
            let reqStr = API.agendaDetail + hashValue
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    self.eventDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let status = self.eventDict.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: self.eventDict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: self.eventDict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: self.eventDict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 406 {
                            Alert.show("Jane", message: self.eventDict.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                    DispatchQueue.main.async {
                        self.lblEventTitle.text = (self.eventDict.value(forKey: "title") as! String)
                        self.lblStudentName.text = ((self.eventDict.value(forKey: "learnersNames") as! NSArray).object(at: 0) as! String)
                        self.lblDescr.text = (self.eventDict.value(forKey: "description") as! String)
                        let startDate = self.eventDict.value(forKey: "startDate") as! String
                        let dateFormat1 = DateFormatter()
                        dateFormat1.dateFormat = "yyyyMMdd"
                        let date = dateFormat1.date(from: startDate)
                        let finalDate = self.convertDateFormate1(date:date!)
                        let time = DateFormat.getTime1(dateStr: self.eventDict.value(forKey: "startTime") as! String)
                        self.lblCalDate.text = finalDate + "   " + time
                        self.eventView.isHidden = false
                        if self.eventDict.value(forKey: "hasAlbum") as! Bool {
                            self.galleryView.isHidden = false
                        } else {
                            self.galleryView.isHidden = true
                        }
                        dateFormat1.dateFormat = "yyyyMMdd"
                        let selDateStr = self.eventDict.value(forKey: "startDate") as! String
                        let selDate = dateFormat1.date(from: selDateStr)
                        
                        if selDate! > Date() {
                            if self.eventDict.value(forKey: "willAttend") as! Bool {
                                self.lblEventPresent.text = "I'll be present"
                                self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaPresent")
                            } else {
                                
                                self.lblEventPresent.text = "I won’t be present"
                                self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaAbsent")
                            }
                            
                        } else {
                            if self.eventDict.value(forKey: "willAttend") as! Bool {
                                self.lblEventPresent.text = "I was present"
                                self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaPresent")
                            } else {
                                
                                self.lblEventPresent.text = "I was not present"
                                self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaAbsent")
                            }
                        }
                    }
                    
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    self.tbl.reloadData()
                    self.calendar.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    func callPermissionAPI() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.permissions
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
                    let arr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    print(arr)
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
    func setEvent() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.agendaDetail + "\(self.eventDict.value(forKey: "eventHash") as! String)"
            
            var parameters: Parameters = [:]
            if self.eventDict.value(forKey: "willAttend") as! Bool {
                parameters = ["willAttend":false]
            } else {
                parameters = ["willAttend":true]
            }
            let headers = [
                "accessToken": (AgendaVC.loginDict.value(forKey: "accessToken") as! String),
                ]
            
            Alamofire.request(reqStr, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                if response.result.isFailure {
                    Progress.hide(toView: self.view)
                }else {
                    Progress.hide(toView: self.view)
                    let data = response.data
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        if dict.count != 0 {
                            if dict.value(forKey:"wasOK") as! NSNumber == 1 {
                                if self.flag == 0 {
                                    self.callAgenda(date: self.currentDate1)
                                } else {
                                    self.callDayAgenda(date:self.currentDate1)
                                }
                                let dateFormat1  = DateFormatter()
                                dateFormat1.dateFormat = "yyyyMMdd"
                                let selDateStr = self.eventDict.value(forKey: "startDate") as! String
                                let selDate = dateFormat1.date(from: selDateStr)
                                let boolVal = self.eventDict.value(forKey: "willAttend") as! Bool
                                if selDate! > Date() {
                                    if !boolVal {
                                        self.lblEventPresent.text = "I'll be present"
                                        self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaPresent")
                                    } else {
                                        
                                        self.lblEventPresent.text = "I won’t be present"
                                        self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaAbsent")
                                    }
                                    
                                } else {
                                    if !boolVal {
                                        self.lblEventPresent.text = "I was present"
                                        self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaPresent")
                                    } else {
                                        
                                        self.lblEventPresent.text = "I was not present"
                                        self.imgEventPresent.image = #imageLiteral(resourceName: "AgendaAbsent")
                                    }
                                }
                            }
                        }
                    } catch _ {
                        Progress.hide(toView: self.view)
                    }
                }
            }
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    @IBAction func btnPreviousClicked(_ sender: Any) {
        let cal = NSCalendar.current
        let date = cal.date(byAdding: .month, value: -1, to: currentDate)
        currentDate = date!
        self.calendar.setCurrentPage(currentDate, animated: true)
        callAgenda(date:currentDate)
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        let cal = NSCalendar.current
        let date = cal.date(byAdding: .month, value: 1, to: currentDate)
        currentDate = date!
        self.calendar.setCurrentPage(currentDate, animated: true)
        callAgenda(date:currentDate)
    }
    
    @IBAction func btnCalClicked(_ sender: Any) {
        calView.isHidden = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        lblMonth3.text = dateFormatter.string(from: Date())
        currentDate1 = Date()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let tmpDateStr = dateFormatter.string(from: currentDate1)
        calendar1.select(self.dateFormatter1.date(from: tmpDateStr))
        let str = convertDateFormate(date: currentDate1)
        print(str)
    }
    func convertDateFormate(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMMM yyyy"
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
    func convertDateFormate2(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMMM yyyy"
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
    func convertDateFormate1(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMMM"
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
    @IBAction func btnNextDay(_ sender: Any) {
        let cal = NSCalendar.current
        let date = cal.date(byAdding: .month, value: 1, to: currentDate1)
        currentDate1 = date!
        self.calendar1.setCurrentPage(currentDate1, animated: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        lblMonth3.text = dateFormatter.string(from: currentDate1)
        callDayAgenda(date: currentDate1)
        calendar1.reloadData()
    }
    
    @IBAction func btnPreviousDay(_ sender: Any) {
        let cal = NSCalendar.current
        let date = cal.date(byAdding: .month, value: -1, to: currentDate1)
        currentDate1 = date!
        self.calendar1.setCurrentPage(currentDate1, animated: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        lblMonth3.text = dateFormatter.string(from: currentDate1)
        callDayAgenda(date: currentDate1)
        calendar1.reloadData()
    }
    
    @IBAction func btnOKClicked(_ sender: Any) {
        eventView.isHidden = true
    }
    @IBAction func btnEventPresentClicked(_ sender: Any) {
        
        let startDate = self.alertDict.value(forKey: "startDate") as! String
        let dateFormat1 = DateFormatter()
        dateFormat1.dateFormat = "yyyyMMdd"
        let date = dateFormat1.date(from: startDate)
        let finalDate = self.convertDateFormate2(date:date!)
        if self.lblEventPresent.text! == "I'll be present" {
            let alertController = UIAlertController(title: "Are you sure you will participate into the event?", message: "\(alertDict.value(forKey: "title") as! String), on \(finalDate), at \(DateFormat.getTime(dateStr: alertDict.value(forKey: "startTime") as! String))", preferredStyle: .alert)
            
            
            // Create the actions
            let okAction = UIAlertAction(title: "Yes, I'm sure", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.setEvent()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                
            }
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        } else if self.lblEventPresent.text! == "I won’t be present" {
            let alertController = UIAlertController(title: "Are you sure you won't participate into the event?", message: "\(alertDict.value(forKey: "title") as! String), on \(finalDate), at \(DateFormat.getTime(dateStr: alertDict.value(forKey: "startTime") as! String))", preferredStyle: .alert)
            
            
            // Create the actions
            let okAction = UIAlertAction(title: "Yes, I'm sure", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.setEvent()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                
            }
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSeePhotoClicked(_ sender: Any) {
        let VC = Common.storyboard.instantiateViewController(withIdentifier: "PhotoGalleryVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC, navigationsController: self.navigationController!, isAnimated: true)
    }
    
    @IBAction func btnMenuClicked(_ sender: Any) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            if !SideMenuView.isOpen {
                
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
    @IBAction func btnAttendanceClcked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceList")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
}
extension AgendaVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! AgendaCell
        if flag == 0 {
            cell.dateLead.constant = 8
            cell.dateWidth.constant = 28
            //cell.dateBottom.isActive = true
            cell.dateHeight.constant = 40
            cell.dateView.isHidden = false
            cell.descTop.constant = 10
        } else {
            cell.dateLead.constant = 0
            cell.dateWidth.constant = 0
            //cell.dateBottom.isActive = false
            cell.dateHeight.constant = 20
            cell.dateView.isHidden = true
            cell.descTop.constant = 0
        }
        self.tblHeight.constant = self.tbl.contentSize.height
        //cell.cardView.setCardView(view: cell.cardView)
        let dict = eventArr.object(at: indexPath.row) as! NSDictionary
        cell.lblDate.text = DateFormat.getDay(dateStr: dict.value(forKey: "startDate") as! String)
        let month = DateFormat.getWeek(dateStr: dict.value(forKey: "startDate") as! String)
        cell.lblWeek.text = weekName[month]
        cell.lblDesc.text = dict.value(forKey: "title") as! String
        cell.lblTime.text = DateFormat.getTime(dateStr: dict.value(forKey: "startTime") as! String)
        if dict.value(forKey: "willAttend") as! NSNumber == 1 {
            cell.imgPresent.image = #imageLiteral(resourceName: "AgendaPresent")
        } else {
            cell.imgPresent.image = #imageLiteral(resourceName: "AgendaAbsent")
        }
        for i in 0..<self.childArr.count {
            let childdict = self.childArr.object(at: i) as! NSDictionary
            if childdict.value(forKey: "learnerHash") as! String == (dict.value(forKey: "learnersHashes") as! NSArray).object(at: 0) as! String {
                let tmpStr = (childdict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
                cell.learnerColor.backgroundColor = UIColor.init(hexString: "#" + String(tmpStr))
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
            // End of loading
            self.tblHeight.constant = self.tbl.contentSize.height
            //cell.cardView.setCardView(view: cell.cardView)
            self.tbl.layoutIfNeeded()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = eventArr.object(at: indexPath.row) as! NSDictionary
        alertDict = dict
        for i in 0..<self.childArr.count {
            let childdict = self.childArr.object(at: i) as! NSDictionary
            if childdict.value(forKey: "learnerHash") as! String == (dict.value(forKey: "learnersHashes") as! NSArray).object(at: 0) as! String {
                let tmpStr = (childdict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
                imgStudentColor.backgroundColor = UIColor.init(hexString: "#" + String(tmpStr))
            }
        }
        callAgendaDetail(hashValue: dict.value(forKey: "eventHash") as! String)
    }
}
extension AgendaVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if 45 * childArr.count > 200 {
            collWidth.constant = 200
        } else {
            collWidth.constant = CGFloat(45 * childArr.count)
        }
        return childArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnerCell", for: indexPath) as! learnerCell
        let dict = (resAgenda.value(forKey: "learners") as! NSArray).object(at: indexPath.row) as! NSDictionary
        let tmpColorStr = (dict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
        cell.lblCount.text = String(describing:(dict.value(forKey: "howMany") as! NSNumber))
        cell.lblCount.textColor = UIColor.init(hexString: "#" + String(tmpColorStr))
        cell.learnerImg.borderColor1 = UIColor.init(hexString: "#" + String(tmpColorStr))
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (dict.value(forKey: "image") as! String))
        
        
        cell.learnerImg.kf.indicatorType = .activity
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 45)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = childArr.object(at: indexPath.row) as! NSDictionary
        callAgendaFilter(date: currentDate,hashValue:dict.value(forKey: "learnerHash") as! String)
    }
}
extension AgendaVC: FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance {

//    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
//        let tmpDate = date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//        let tmpStr = dateFormatter.string(from: tmpDate)
//        let dateArr = eventArr.value(forKey: "startDate") as! NSArray
//        if(dateArr.contains(tmpStr)){
//            dateFormatter.dateFormat = "yyyy/MM/dd"
//            calendar.select(dateFormatter.date(from: tmpStr))
//            return true
//        }else{
//            return false
//        }
//    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        //let day = calendar.dayOfDate(date)
        //print(arrDatstoCheck)
        if calendar == calendar1 {
            return 0
        }
        else  {
            let tmpDate = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let tmpStr = dateFormatter.string(from: tmpDate)
            let dateArr = eventArr.value(forKey: "startDate") as! NSArray
            if(dateArr.contains(tmpStr)){
                dateFormatter.dateFormat = "yyyyMMdd"
                let tmpDate = dateFormatter.date(from: tmpStr)
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let tmpDateStr = dateFormatter.string(from: tmpDate!)
                calendar.select(self.dateFormatter1.date(from: tmpDateStr))
                return 1
            }else{
                return 0
            }
        }

    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate1 = date
        callDayAgenda(date: currentDate1)
        calView.isHidden = true
        self.lblDate.text = convertDateFormate(date: date)
        self.calendar1.reloadData()
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if  calendar == calendar1 {
            let dateFor = DateFormatter()
            dateFor.dateFormat = "dd/MM/yyyy"
            let tmpDate = dateFor.string(from: date)
            let tmpDat1 = dateFor.string(from: currentDate1)
            print(tmpDate)
            print(tmpDat1)
            if tmpDate == tmpDat1 {
                return UIColor.init(hexString: "#" + String("FFFFF"))
            } else {
                return UIColor.clear
            }
        }
        else  {
            let tmpDate = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let tmpStr = dateFormatter.string(from: tmpDate)
            let dateArr = eventArr.value(forKey: "startDate") as! NSArray
            if(dateArr.contains(tmpStr)){
                let index = dateArr.index(of: tmpStr)
                let dict = self.eventArr.object(at: index) as! NSDictionary
                for i in 0..<self.childArr.count {
                    let childdict = self.childArr.object(at: i) as! NSDictionary
                    if childdict.value(forKey: "learnerHash") as! String == (dict.value(forKey: "learnersHashes") as! NSArray).object(at: 0) as! String {
                        let tmpStr = (childdict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
                        return UIColor.init(hexString: "#" + String(tmpStr))
                    }
                }
                
            }
            return UIColor.clear
        }
    }
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//
//        if  calendar == calendar1 {
//            let dateFor = DateFormatter()
//            dateFor.dateFormat = "dd/MM/yyyy"
//            let tmpDate = dateFor.string(from: date)
//            let tmpDat1 = dateFor.string(from: currentDate1)
//            print(tmpDate)
//            print(tmpDat1)
//            if tmpDate == tmpDat1 {
//                return UIColor.white
//            } else {
//                return UIColor.black
//            }
//        } else {
//            return nil
//        }
//    }
}
