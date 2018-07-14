//
//  LoginVC.swift
//  Jane
//
//  Created by Rujal on 5/30/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
//        let VC = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceList")
//        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
        if txtUsername.text! == "" {
            Alert.show("Jane", message: "Por favor, informe o seu nome de usuário", onVC: self)
        } else if txtPassword.text! == "" {
            Alert.show("Jane", message: "Por favor, informe a sua senha", onVC: self)
        } else {
            callLogin()
        }
    }
    func callLogin() {
        if Reachability.isConnectedToNetwork() {
            if Reachability.isConnectedToNetwork() {
                Progress.show(toView: self.view)
                let reqParam = ["appHash":"KSMRERN_OPD_2018_BSOFSTVRTYP","userName":txtUsername.text!,"password":txtPassword.text!]
                AFWrapper.requestPOSTURL(API.login, params: reqParam as [String : AnyObject], headers: nil, success: { (resultObj) in
                    Progress.hide(toView: self.view)
                    let dict = resultObj.dictionaryObject! as NSDictionary
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
                    
                    let namesArrayData = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(true, forKey: "AlreadyLogin")
                    UserDefaults.standard.set(namesArrayData, forKey: "loginResponse")
                    let VC = Common.storyboard.instantiateViewController(withIdentifier: "AgendaVC")
                   Common.navigationController.pushViewController(VC, animated: true) 
                    print(dict)
                }) { (error) in
                    Progress.hide(toView: self.view)
                    Alert.requestTimeOut()
                }
            } else {
                Progress.hide(toView: self.view)
                Alert.internetConnectionError()
            }
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC")
        Navigation.push_POP_to_ViewController(destinationVC: VC!, navigationsController: self.navigationController!, isAnimated: true)
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtUsername == textField {
            txtPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
