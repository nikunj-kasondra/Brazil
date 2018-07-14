//
//  MonthKeysVC.swift
//  Jane
//
//  Created by Rujal on 6/5/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Alamofire

class MonthKeysVC: UIViewController {

    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var imgPay: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblSubTitlle: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    static var billHash = ""
    var dict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callMonthKeys()
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
    func callMonthKeys() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            let reqStr = API.monthPayments + MonthKeysVC.billHash
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
                                Alert.show("Jane", message: self.dict.value(forKey: "message") as! String, onVC: self)
                            } else if status == 406 {
                                Alert.show("Jane", message: self.dict.value(forKey: "message") as! String, onVC: self)
                            }
                            Progress.hide(toView: self.view)
                            return
                        }
                    DispatchQueue.main.async {
                        self.lblMonth.text = self.dict.value(forKey: "month") as? String
                        self.lblSubTitlle.text = self.dict.value(forKey: "subtitle") as? String
                        self.lblDesc.text = self.dict.value(forKey: "description") as? String
                        if self.dict.value(forKey: "payed") as! NSNumber == 0 {
                            self.imgPay.image = #imageLiteral(resourceName: "Red_Correct")
                        } else {
                            self.imgPay.image = #imageLiteral(resourceName: "Blue_Correct")
                        }
                        self.lblKey.text = self.dict.value(forKey: "billHash") as? String
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
    
    @IBAction func btnKeysClicked(_ sender: Any) {
        UIPasteboard.general.string = self.lblKey.text!
    }
    
    @IBAction func btnDownloadClicked(_ sender: Any) {
        Progress.show(toView: self.view)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(MonthKeysVC.billHash).pdf")
            return (documentsURL, [.removePreviousFile])
        }

        let url = self.dict.value(forKey: "file") as! String
        Alamofire.download(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: ["accessToken":(AgendaVC.loginDict.value(forKey: "accessToken") as! String)],
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
            }).response(completionHandler: { (DefaultDownloadResponse) in
                print(DefaultDownloadResponse.destinationURL!)
                self.openPDF()
            })
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func openPDF() {
        let fileManager = FileManager.default
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as? String ?? ""
        let fileName = MonthKeysVC.billHash + ".pdf"
        let writablePath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName).path
    
        
        if fileManager.fileExists(atPath:writablePath) {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let fileURL = path + "/" + MonthKeysVC.billHash + ".pdf"
            let interactionController = UIDocumentInteractionController(url: URL.init(fileURLWithPath: fileURL))
            interactionController.delegate = self
            interactionController.presentPreview(animated: true)
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
extension MonthKeysVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("End")
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        Progress.hide(toView: self.view)
        return self
    }
}
