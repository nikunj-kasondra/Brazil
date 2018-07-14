//
//  NewsInfoVC.swift
//  Jane
//
//  Created by Rujal on 7/1/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class NewsInfoVC: UIViewController {
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = NewsTitleVC.newsDict.value(forKey: "title") as? String
        lblAuthor.text = NewsTitleVC.newsDict.value(forKey: "author") as? String
        let dateStr = NewsTitleVC.newsDict.value(forKey: "date") as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: dateStr)
        lblDate.text = convertDateFormate(date: date!)
        lblDesc.text = NewsTitleVC.newsDict.value(forKey: "description") as? String
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (NewsTitleVC.newsDict.value(forKey: "image") as! String))
        
        
        imgAuthor.kf.indicatorType = .activity
        imgAuthor.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                
            } else {
                // handle the failure
                print(error)
            }
        }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnNoClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnYes.backgroundColor = UIColor.white
            self.btnNo.backgroundColor = Common.blueColor
            self.btnYes.setTitleColor(UIColor.black, for: .normal)
            self.btnNo.setTitleColor(UIColor.white, for: .normal)
        }
        callNews(flag: false)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnYesClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnYes.backgroundColor = Common.blueColor
            self.btnNo.backgroundColor = UIColor.white
            self.btnYes.setTitleColor(UIColor.white, for: .normal)
            self.btnNo.setTitleColor(UIColor.black, for: .normal)
        }
        callNews(flag: true)
    }
    func callNews(flag:Bool) {
        
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.news + "/5GbmhakYkCpllFYGpHPNYW"
            var parameters: Parameters = [:]
            parameters = ["confirmation":flag]
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
                            if dict.value(forKey:"wasOK") as! NSNumber == 1 {
                                
                                Alert.show("Jane", message: "Confirmação enviada com sucesso", onVC: self)
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
