//
//  TeacherVC.swift
//  Jane
//
//  Created by Rujal on 7/12/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class TeacherVC: UIViewController {

    @IBOutlet weak var tblTeacher: UITableView!
    var teacherArr = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblTeacher.register(UINib(nibName: "TeacherCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblTeacher.separatorStyle = .none
        callTeacherList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func callTeacherList() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.educatorsList 
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
                    self.teacherArr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    print(self.teacherArr)
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.tblTeacher.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
}

extension TeacherVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacherArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! TeacherCell
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (self.teacherArr.value(forKey: "thumbnailImage") as! NSArray).object(at: indexPath.row) as! String)
        
        
        cell.imgTeacher.kf.indicatorType = .activity
        cell.imgTeacher.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                
            } else {
                // handle the failure
                print(error)
            }
        }
        
        cell.lblName.text = ((self.teacherArr.value(forKey: "name") as! NSArray).object(at: indexPath.row) as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TeacherCurriculum.learnerHash = (self.teacherArr.value(forKey: "educatorHash") as! NSArray).object(at: indexPath.row) as! String
        TeacherCurriculum.headerName = (self.teacherArr.value(forKey: "name") as! NSArray).object(at: indexPath.row) as! String
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherCurriculum")
        self.navigationController?.pushViewController(VC!, animated: true)
    }
}
