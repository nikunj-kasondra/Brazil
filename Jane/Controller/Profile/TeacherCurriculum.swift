//
//  TeacherCurriculum.swift
//  Jane
//
//  Created by Rujal on 6/7/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class TeacherCurriculum: UIViewController {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    static var learnerHash = ""
    static var headerName = ""
    @IBOutlet weak var lblTeacherName: UILabel!
    @IBOutlet weak var imgSmall: UIImageView!
    @IBOutlet weak var imgBig: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = TeacherCurriculum.headerName
        lblTeacherName.text = TeacherCurriculum.headerName
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
            let reqStr = API.educatorsList + "/\(TeacherCurriculum.learnerHash)"
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
                        self.lblDesc.text = dict.value(forKey: "curriculum") as? String
                        let modifier = AnyModifier { request in
                            var r = request
                            // replace "Access-Token" with the field name you need, it's just an example
                            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
                            return r
                        }
                        
                        let url = URL(string: dict.value(forKey: "image") as! String)
                        
                        
                        self.imgBig.kf.indicatorType = .activity
                        self.imgBig.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
                            if error == nil && image != nil {
                                // here the downloaded image is cached, now you need to set it to the imageView
                                
                            } else {
                                // handle the failure
                                print(error)
                            }
                        }
                        self.imgSmall.kf.indicatorType = .activity
                        self.imgSmall.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
                            if error == nil && image != nil {
                                // here the downloaded image is cached, now you need to set it to the imageView
                                
                            } else {
                                // handle the failure
                                print(error)
                            }
                        }
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
    
    @IBAction func btnSendMessage(_ sender: Any) {
    }
    
}
