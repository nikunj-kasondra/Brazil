//
//  ChatListVC.swift
//  Jane
//
//  Created by Rujal on 7/10/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class ChatListVC: UIViewController {

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    var chatListArr = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblChat.register(UINib(nibName: "OtherChatCell", bundle: nil), forCellReuseIdentifier: "OtherChatCell")
        tblChat.register(UINib(nibName: "MyChatCell", bundle: nil), forCellReuseIdentifier: "MyChatCell")
        tblChat.separatorStyle = .none
        if ChatVC.tab == 0 {
            callDeparmentList()
        } else {
            callEducatorList()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func callDeparmentList() {
        if Reachability.isConnectedToNetwork() {
            
            let reqStr = API.departmentMessages + ChatVC.hashVal + "/messages"
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
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
    func callEducatorList() {
        if Reachability.isConnectedToNetwork() {
            
            let reqStr = API.educatorsMessages + ChatVC.hashVal + "/messages"
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

    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ChatListVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyChatCell") as! MyChatCell
            return cell
    }
}
