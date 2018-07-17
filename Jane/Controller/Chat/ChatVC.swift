//
//  ChatVC.swift
//  Jane
//
//  Created by Rujal on 7/9/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl1: UILabel!
    static var tab:Int = 0
    var departmentArr = NSArray()
    var educatorArr = NSArray()
    static var hashVal = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl1.isHidden = false
        lbl2.isHidden = true
        tblChat.register(UINib(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblChat.separatorStyle = .none
        tblChat.rowHeight = UITableViewAutomaticDimension
        callChatList()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func btnDepartmentClicked(_ sender: Any) {
        lbl2.isHidden = true
        lbl1.isHidden = false
        ChatVC.tab = 0
        DispatchQueue.main.async {
            self.tblChat.reloadData()
        }
    }
    
    @IBAction func btnEducatorClicked(_ sender: Any) {
        lbl2.isHidden = false
        lbl1.isHidden = true
        ChatVC.tab = 1
        DispatchQueue.main.async {
            self.tblChat.reloadData()
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
    func callChatList() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.messages
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
                    self.departmentArr = dict.value(forKey: "departments") as! NSArray
                   self.educatorArr = dict.value(forKey: "educators") as! NSArray
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.tblChat.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
}
extension ChatVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ChatVC.tab == 0 {
            return departmentArr.count
        } else {
            return educatorArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! ChatListCell
        if ChatVC.tab == 0 {
            cell.lblTitle.text = (departmentArr.value(forKey: "departmentName") as! NSArray).object(at: indexPath.row) as? String
            cell.lblDesc.text = (departmentArr.value(forKey: "lastMessage") as! NSArray).object(at: indexPath.row) as? String
        } else {
            cell.lblTitle.text = (educatorArr.value(forKey: "educatorName") as! NSArray).object(at: indexPath.row) as? String
            cell.lblDesc.text = (educatorArr.value(forKey: "lastMessage") as! NSArray).object(at: indexPath.row) as? String
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ChatVC.tab == 0 {
            ChatListVC.headerName = (departmentArr.value(forKey: "departmentName") as! NSArray).object(at: indexPath.row) as! String
            ChatVC.hashVal = (self.departmentArr.value(forKey: "departmentHash") as! NSArray).object(at: indexPath.row) as! String
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatListVC")
            self.navigationController?.pushViewController(VC!, animated: true)
        } else {
            ChatListVC.headerName = (educatorArr.value(forKey: "educatorName") as! NSArray).object(at: indexPath.row) as! String
            ChatVC.hashVal = (self.educatorArr.value(forKey: "educatorHash") as! NSArray).object(at: indexPath.row) as! String
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatListVC")
            self.navigationController?.pushViewController(VC!, animated: true)
        }
    }
}
