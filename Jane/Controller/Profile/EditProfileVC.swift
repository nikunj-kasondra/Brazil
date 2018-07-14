//
//  EditProfileVC.swift
//  Jane
//
//  Created by Rujal on 6/10/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class EditProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var pickerController = UIImagePickerController()
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtAbout: UITextField!
    @IBOutlet weak var txtAdress: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    var tmpImage:UIImage? = nil
    static var address = ""
    static var isAddress = false
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imgProfile.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                // here the downloaded image is cached, now you need to set it to the imageView
                DispatchQueue.main.async {
                    self.imgProfile.image = image
                    self.tmpImage = image
                }
            } else {
                // handle the failure
                print(error)
            }
        }
        callGetProfile()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        Common.navigationController.isNavigationBarHidden = true
        if EditProfileVC.isAddress {
            EditProfileVC.isAddress = false
            txtAdress.text = EditProfileVC.address
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func callGetProfile() {
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            
            var request = URLRequest(url: URL(string: API.beforeEdit)!)
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
                    if dict.count != 0 {
                        DispatchQueue.main.async {
                            self.txtAdress.text = (dict.value(forKey: "address") as! String)
                            self.txtGender.text = (dict.value(forKey: "gender") as! String)
                            self.txtUsername.text = (dict.value(forKey: "name") as! String)
                            self.txtAbout.text = (dict.value(forKey: "about") as! String)
                            self.txtPhone.text = (dict.value(forKey: "phone") as? String)
                            let dateStr = (dict.value(forKey: "birthDate") as! String)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyyMMdd"
                            let date = dateFormatter.date(from: dateStr)
                            dateFormatter.dateFormat = "MMMM dd, yyyy"
                            self.txtDOB.text = dateFormatter.string(from: date!)
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
    
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @IBAction func btnMapClicked(_ sender: Any) {
        Common.navigationController.isNavigationBarHidden = false
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PlaceVC")
        self.navigationController?.pushViewController(VC!, animated: true)
    }
    @IBAction func btnCalendarClicked(_ sender: Any) {
        
        DatePickerDialog().show(title:"Choose Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            self.txtDOB.text = dateFormatter.string(from: date as Date)
        }
    }
    @IBAction func btnSaveClicked(_ sender: Any) {
        Progress.show(toView: self.view)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let date = dateFormatter.date(from: txtDOB.text!)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date!)
        let post = [
            "name": txtUsername.text!,
            "about": txtAbout.text!,
            "birthDate": dateStr,"gender":txtGender.text!,"address":txtAdress.text!,"phone":txtPhone.text!]
        
        
        if !Reachability.isConnectedToNetwork() {
            Alert.internetConnectionError()
        } else {
            var myThumb1 = UIImage()
            var data = Data()
            //if tmpImage != nil {
                myThumb1 =  self.tmpImage!.resized(withPercentage: 0.1)!
                data = UIImagePNGRepresentation(myThumb1)!
//            } else {
//                myThumb1 =  self.imgProfile.image!.resized(withPercentage: 0.1)!
//                data = UIImagePNGRepresentation(myThumb1)!
//            }
            
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "image", fileName: "nikunj.jpg", mimeType: "image/jpeg")
                
                for (key, value) in post {
                    let valueStr = String(describing: value)
                    multipartFormData.append((valueStr.data(using:.utf8))!, withName: key)
                }}, to: API.edit, method: .post, headers: ["accessToken":AgendaVC.loginDict.value(forKey: "accessToken") as! String],
                    encodingCompletion: { encodingResult in
                        Progress.hide(toView: (self.navigationController?.view)!)
                        switch encodingResult {
                        case .success(let upload, _, _):
                            
                            upload.response { [weak self] response in
                                guard self != nil else {
                                    Progress.hide(toView: (self?.view)!)
                                    return
                                }
                                do {
                                    let dict = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! NSDictionary
                                    Progress.hide(toView: (self?.view)!)
                                    if let status = dict.value(forKey: "status") as? NSNumber {
                                        if status == 403 {
                                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self!)
                                        } else if status == 500 {
                                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self!)
                                        } else if status == 400 {
                                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self!)
                                        } else if status == 403 {
                                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self!)
                                        }
                                        return
                                    }
                                    if dict.value(forKey: "wasOK") as! NSNumber == 1 {
                                        Alert.show("Jane", message: "Perfil atualizado com sucesso.", onVC: self!)
                                    } else {
                                        Alert.show("Jane", message: "Algo deu errado. Por favor, tente novamente.", onVC: self!)
                                    }
                                } catch _ {
                                    
                                }
                            }
                        case .failure(let encodingError):
                            Progress.hide(toView: self.view)
                            print("error:\(encodingError)")
                        }
            })
        }
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
        tmpImage = imageView
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}
extension EditProfileVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
