//
//  NewsVC.swift
//  Jane
//
//  Created by Rujal on 7/1/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class NewsVC: UIViewController {
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var collWidth: NSLayoutConstraint!
    @IBOutlet weak var learnerColl: UICollectionView!
    var childArr = NSArray()
    var newsArr = NSArray()
    var tmpNewsArr = NSMutableArray()
    @IBOutlet weak var tblNews: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        learnerColl.register(UINib(nibName: "learnerCell", bundle: nil), forCellWithReuseIdentifier: "learnerCell")
        tblNews.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblNews.separatorStyle = .none
        tblNews.rowHeight = UITableViewAutomaticDimension
        callNews()
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
    func callNews() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.news
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
                    self.childArr = (dict.value(forKey: "learnersFilter") as! NSArray)
                    self.newsArr = (dict.value(forKey: "news") as! NSArray)
                    self.tmpNewsArr = (dict.value(forKey: "news") as! NSArray).mutableCopy() as! NSMutableArray
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.learnerColl.reloadData()
                    self.tblNews.reloadData()
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
    @objc func NewsDetail(sender:UIButton) {
        NewsTitleVC.newsDict = tmpNewsArr.object(at: sender.tag) as! NSDictionary
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewsInfoVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
    @objc func NewsTitleDetail(sender:UIButton) {
        for k in 0..<childArr.count {
            let dict2 = childArr.object(at: k) as! NSDictionary
            let dict1 = tmpNewsArr.object(at: sender.tag) as! NSDictionary
            let tmpArr = dict1.value(forKey: "learnersHashes") as! NSArray
            for j in 0..<tmpArr.count {
                if dict2.value(forKey: "learnerHash") as! String == tmpArr.object(at: j) as! String {
                    NewsTitleVC.hexColor = dict2.value(forKey: "hexColor") as! String
                    break
                }
            }
        }
        NewsTitleVC.newsDict = tmpNewsArr.object(at: sender.tag) as! NSDictionary
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewsTitleVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)

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
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    
    @IBAction func btnAttendanceClcked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceList")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
}
extension NewsVC:UICollectionViewDelegate,UICollectionViewDataSource {
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 45, height: 45)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = childArr.object(at: indexPath.row) as! NSDictionary
        self.tmpNewsArr.removeAllObjects()
        for i in 0..<self.newsArr.count {
            let dict1 = newsArr.object(at: i) as! NSDictionary
            let tmpArr = dict1.value(forKey: "learnersHashes") as! NSArray
            for j in 0..<tmpArr.count {
                if dict.value(forKey: "learnerHash") as! String == tmpArr.object(at: j) as! String {
                    self.tmpNewsArr.add(self.newsArr.object(at: i) as! NSDictionary)
                }
            }
            
        }
        DispatchQueue.main.async {
            self.tblNews.reloadData()
        }
    }
}
extension NewsVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpNewsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! NewsCell
        let dict = tmpNewsArr.object(at: indexPath.row) as! NSDictionary
        cell.lblTitle.text = dict.value(forKey: "title") as? String
        cell.lblAuthor.text = dict.value(forKey: "author") as? String
        cell.lblAuthor1.text = dict.value(forKey: "author") as? String
//        if dict.value(forKey: "requirePositioning") as! Bool {
//            cell.bottomView.isHidden = false
//            //cell.participateHeight.isActive = true
//        } else {
//            cell.bottomView.isHidden = true
//            //cell.participateHeight.constant = 0
//            //cell.participateHeight.isActive = false
//        }
        for k in 0..<childArr.count {
        let dict2 = childArr.object(at: k) as! NSDictionary
        for i in 0..<self.tmpNewsArr.count {
            let dict1 = tmpNewsArr.object(at: i) as! NSDictionary
            let tmpArr = dict1.value(forKey: "learnersHashes") as! NSArray
            for j in 0..<tmpArr.count {
                if dict2.value(forKey: "learnerHash") as! String == tmpArr.object(at: j) as! String {
                    let tmpStr = (dict.value(forKey: "hexColor") as! String).replacingOccurrences(of: "#", with: "")
                    cell.sideView.backgroundColor = UIColor.init(hexString: "#" + String(tmpStr))
                    break
                }
            }
            }
        }
        let dateStr = dict.value(forKey: "date") as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: dateStr)
        cell.lblDate.text = convertDateFormate(date: date!)
        cell.lblDate1.text = convertDateFormate(date: date!)
        cell.lblDesc.text = dict.value(forKey: "description") as? String
        cell.lblDesc1.text = dict.value(forKey: "description") as? String
        cell.btnImage.addTarget(self, action: #selector(NewsVC.NewsDetail), for: .touchUpInside)
        cell.btnTitle.addTarget(self, action: #selector(NewsVC.NewsTitleDetail), for: .touchUpInside)
        cell.btnImage.tag = indexPath.row
        cell.btnTitle.tag = indexPath.row
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (dict.value(forKey: "image") as! String))
        
        
        cell.imgNews.kf.indicatorType = .activity
        cell.imgNews.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                
            } else {
                // handle the failure
                print(error)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
