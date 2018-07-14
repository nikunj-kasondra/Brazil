//
//  PhotoDetailVC.swift
//  Jane
//
//  Created by Rujal on 6/10/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoDetailVC: UIViewController {

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    static var photoHash = String()
    var dict = NSDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
        callAllPhoto()
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
    @IBAction func btnShareClicked(_ sender: Any) {
        let shareText = lblTitle.text!
        
        if let image = imgCover {
            let vc = UIActivityViewController(activityItems: [shareText, image], applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    func callAllPhoto() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.photoList + "\(GalleryPhoto.hashValue)/photos/" + PhotoDetailVC.photoHash
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    self.dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let status = self.dict.value(forKey: "status") as? NSNumber {
                            if status == 403 {
                                Alert.show("Jane", message: self.dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 500 {
                                Alert.show("Jane", message: self.dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 400 {
                                Alert.show("Jane", message: self.self.dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 406 {
                                Alert.show("Jane", message: self.dict.value(forKey: "message") as! String, onVC: self)
                            }
                            Progress.hide(toView: self.view)
                            return
                        }
                    let modifier = AnyModifier { request in
                        var r = request
                        // replace "Access-Token" with the field name you need, it's just an example
                        r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
                        return r
                    }
                    DispatchQueue.main.async {
                        let dateStr = self.dict.value(forKey: "date") as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd"
                        let date = dateFormatter.date(from: dateStr)
                        dateFormatter.dateFormat = "dd MMMM yyyy"
                        self.lblDate.text = dateFormatter.string(from: date!)
                        if let desc = self.dict.value(forKey: "description") as? String {
                            if self.dict.value(forKey: "description") as! String != "<null>"{
                                self.lblDesc.text = self.dict.value(forKey: "description") as! String
                            }
                        }
                        self.lblTitle.text = self.dict.value(forKey: "title") as? String
                        let url = URL(string: (self.dict.value(forKey: "image") as! String))
                        
                        self.imgCover.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
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
