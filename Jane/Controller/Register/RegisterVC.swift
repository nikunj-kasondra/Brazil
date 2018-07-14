//
//  RegisterVC.swift
//  Jane
//
//  Created by Rujal on 5/31/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit
class RegisterVC: UIViewController {

    @IBOutlet weak var txtSchool: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var instituteSpinner: LBZSpinner!
    @IBOutlet weak var citySpinner: LBZSpinner!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtFname: UITextField!
    var cityDict = NSDictionary()
    var schoolArr = NSArray()
    var educationalInstitutionHash = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        callCity()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func callCity() {
        if Reachability.isConnectedToNetwork() {
            if Reachability.isConnectedToNetwork() {
                Progress.show(toView: self.view)
                let reqParam = ["appHash":"KSMRERN_OPD_2018_BSOFSTVRTYP"]
                AFWrapper.requestPOSTURL(API.beforeSigningUp, params: reqParam as [String : AnyObject], headers: nil, success: { (resultObj) in
                    
                    Progress.hide(toView: self.view)
                    let dict = resultObj.dictionaryObject! as NSDictionary
                    self.cityDict = dict
                    if let status = dict.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                    if self.cityDict.count != 0 {
                    let cityArr = self.cityDict.value(forKey: "cities") as! [String]
                    self.citySpinner.updateList(cityArr)
                    self.citySpinner.delegate = self
                    }
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
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRegisterClicked(_ sender: Any) {
        if txtFname.text! == "" {
            Alert.show("Jane", message: "Por favor, informe o seu nome", onVC: self)
        } else if txtLname.text! == "" {
            Alert.show("Jane", message: "Por favor, informe o seu sobrenome", onVC: self)
        } else if txtEmail.text! == "" {
            Alert.show("Jane", message: "Por favor, informe o seu endereço de e-mail", onVC: self)
        } else if txtPassword.text! == "" {
            Alert.show("Jane", message: "Por favor, informe uma senha secreta", onVC: self)
        } else if txtCity.text! == "" {
            Alert.show("Jane", message: "Por favor insira a cidade", onVC: self)
        } else if txtSchool.text! == "" {
            Alert.show("Jane", message: "Por favor entre na escola", onVC: self)
        } else {
            callRegisterAPI()
        }
        
    }
    
    func callRegisterAPI() {
        if Reachability.isConnectedToNetwork() {
            if Reachability.isConnectedToNetwork() {
                Progress.show(toView: self.view)
                let reqParam = ["appHash":"KSMRERN_OPD_2018_BSOFSTVRTYP","firstName":txtFname.text!,"lastName":txtLname.text!,"email":txtEmail.text!,"password":txtPassword.text!,"educationalInstitutionHash":educationalInstitutionHash]
                AFWrapper.requestPOSTURL(API.signUp, params: reqParam as [String : AnyObject], headers: nil, success: { (resultObj) in
                    
                    Progress.hide(toView: self.view)
                    let dict = resultObj.dictionaryObject! as NSDictionary
                    if let status = dict.value(forKey: "status") as? NSNumber {
                        if status == 403 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 500 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        } else if status == 400 {
                            Alert.show("Jane", message: dict.value(forKey: "message") as! String, onVC: self)
                        }
                        Progress.hide(toView: self.view)
                        return
                    }
                    if dict.value(forKey: "wasOK") as! NSNumber == 1 {
                        let alertController = UIAlertController(title: "Jane", message: "Sua solicitação foi encaminhada com sucesso. Entraremos em contato em breve.", preferredStyle: .alert)
                        
                        // Create the actions
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            self.navigationController?.popViewController(animated: true)
                        }
                        // Add the actions
                        alertController.addAction(okAction)
                        
                        // Present the controller
                        self.present(alertController, animated: true, completion: nil)
                        
                    } else {
                        Alert.show("Jane", message: "Algo deu errado. Por favor, tente novamente", onVC: self)
                    }
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
    
   
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFname {
            txtLname.becomeFirstResponder()
        } else if textField == txtLname {
            txtEmail.becomeFirstResponder()
        } else if textField == txtEmail {
            txtPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
extension RegisterVC: LBZSpinnerDelegate {
    func spinnerChoose(_ spinner: LBZSpinner, index: Int, value: String) {
        print("Spinner : \(spinner) : { Index : \(index) - \(value) }")
        if spinner == citySpinner {
            let cityArr = self.cityDict.value(forKey: "cities") as! [String]
            self.txtCity.text = cityArr[index]
            self.schoolArr = ((self.cityDict.value(forKey: "cityToEducationalInstitutions") as! NSDictionary).value(forKey: cityArr[index]) as! NSArray)
            let schoolName = self.schoolArr.value(forKey: "name") as! [String]
            self.instituteSpinner.updateList(schoolName)
            self.instituteSpinner.delegate = self
        } else {
            self.educationalInstitutionHash = (self.schoolArr.value(forKey: "educationalInstitutionHash") as! NSArray).object(at: index) as! String
            self.txtSchool.text = (self.schoolArr.value(forKey: "name") as! NSArray).object(at: index) as! String
        }
    }
}

