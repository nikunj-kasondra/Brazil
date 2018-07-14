//
//  UserProfileVC.swift
//  Jane
//
//  Created by Rujal on 6/5/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class UserProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var lblNumNotification: UILabel!
    @IBOutlet weak var lblSubUserName: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgSmall: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    var pickerController = UIImagePickerController()
    var notificationArr = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNotification.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "newCell")
        tblNotification.rowHeight = UITableViewAutomaticDimension
        tblNotification.estimatedRowHeight = 44
        tblNotification.separatorStyle = .none
        lblUserName.text = ((AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userName") as! String)
        lblSubTitle.text = ((AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userDescription") as! String)
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("Hi, ")
            .bold(((AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userName") as! String))
            .normal(" How are you?")
        lblSubUserName.attributedText = formattedString
        callNotification()
        //callProfile()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (AgendaVC.loginDict.value(forKey: "profile") as! NSDictionary).value(forKey: "userType") as! String != "RESPONSIBLE" {
            SideMenuView1.btnIndex = 6
            SideMenuView1.add(toVC: self, toView: self.view)
            teacherView.isHidden = false
            studentView.isHidden = true

        }
        else {
            SideMenuView.btnIndex = 6
            SideMenuView.add(toVC: self, toView: self.view)
            teacherView.isHidden = true
            studentView.isHidden = false
        }
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: ("http://67.205.107.224:6223/jane/mobile/users/profile/image"))
        //
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        imgProfile.kf.indicatorType = .activity
        imgSmall.kf.indicatorType = .activity
        imgProfile.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                DispatchQueue.main.async {
                    self.imgProfile.image = image
                    self.imgSmall.image = image
                }
            } else {
                // handle the failure
                print(error)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*func callProfile() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.profile + "accessToken=\(AgendaVC.loginDict.value(forKey: "accessToken") as! String)"
            AFWrapper.requestGETURL(reqStr, success: { (resultObj) in
                Progress.hide(toView: self.view)
                let dict = resultObj.dictionaryObject! as NSDictionary
                if let status = dict.value(forKey: "status") as? NSNumber {
                    if status == 403 {
                        Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                    } else if status == 500 {
                        Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                    }
                    return
                } else {
                    self.lblUserName.text = (dict.value(forKey: "userName") as! String)
                    self.lblSubTitle.text = (dict.value(forKey: "userDescription") as! String)
                    self.lblSubUserName.text = (dict.value(forKey: "userName") as! String)
                    self.imgProfile.kf.setImage(with: URL(string: dict.value(forKey: "imageURL") as! String + String("?accessToken=\(AgendaVC.loginDict.value(forKey: "accessToken") as! String)")))
                    self.imgSmall.kf.setImage(with: URL(string: dict.value(forKey: "imageURL") as! String + String("?accessToken=\(AgendaVC.loginDict.value(forKey: "accessToken") as! String)")))
                    self.callNotification()
                }
                
            }) { (error) in
                Progress.hide(toView: self.view)
                Alert.requestTimeOut()
            }
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    } */
    func convertDate(unixtimeInterval:Double)-> String {
        let date = Date(timeIntervalSince1970: unixtimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd HH:mm:ss" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    func callNotification() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.notification + "initial=0&howMany=10"
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
                    self.notificationArr = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    print(self.notificationArr)
                    let formattedString1 = NSMutableAttributedString()
                    formattedString1
                        .normal("There are ")
                        .bold(String(self.notificationArr.count) + " new notifications")
                        .normal(" for you...")
                    DispatchQueue.main.async {
                        self.lblNumNotification.attributedText = formattedString1
                    }
                    
                    Progress.hide(toView: self.view)
                } catch _ {
                    Progress.hide(toView: self.view)
                }
                DispatchQueue.main.async {
                    self.tblNotification.reloadData()
                }
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    
    @IBAction func btnMedalClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MedalVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
    @IBAction func btnCameraClicked(_ sender: Any) {
        let actionSheetController = UIAlertController(title: "", message: "Choose Option", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            self.openGallary()
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.openCamera()
        }
        actionSheetController.addAction(saveActionButton)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        actionSheetController.addAction(cancel)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.allowsEditing = true
            self .present(self.pickerController, animated: true, completion: nil)
        }
        else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageView = info[UIImagePickerControllerEditedImage] as! UIImage
        imgProfile.image = imageView
        imgSmall.image = imageView
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    @IBAction func btnClockClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "RoutineVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnAgendaClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AgendaVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
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
    
    @IBAction func btnChatClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnNewsClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnAttendanceClcked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceList")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: false)
    }
    @IBAction func btnEditClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
}
extension UserProfileVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell") as! NotificationCell
        let dict = self.notificationArr.object(at: indexPath.row) as! NSDictionary
        cell.lblName.text = (dict.value(forKey: "senderName") as! String)
        cell.lblDate.text = self.convertDate(unixtimeInterval: Double(dict.value(forKey: "date") as! String)!)
        cell.lblDesc.text = (dict.value(forKey: "description") as! String)
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            return r
        }
        
        let url = URL(string: (dict.value(forKey: "image") as! String))
        
        cell.imgNotification.kf.indicatorType = .activity
        cell.imgNotification.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
            // End of loading
            self.tblHeight.constant = self.tblNotification.contentSize.height
            //cell.cardView.setCardView(view: cell.cardView)
            self.tblNotification.layoutIfNeeded()
        }
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 13)!]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
