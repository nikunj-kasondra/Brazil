//
//  ForgotPasswordVC.swift
//  Jane
//
//  Created by Rujal on 5/31/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSubmitClicked(_ sender: Any) {
        if txtEmail.text! == "" {
            Alert.show("Jane", message: "Por favor, informe o seu e-mail", onVC: self)
        } else {
            callFOrgotPassword()
        }
    }
    func callFOrgotPassword() {
        
        if Reachability.isConnectedToNetwork() {
            Progress.show(toView: self.view)
            var reqStr = API.recoveryPassword + txtEmail.text!
            reqStr = reqStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            var request = URLRequest(url: URL(string: reqStr)!)
            request.httpMethod = "GET"
            //request.setValue((AgendaVC.loginDict.value(forKey: "accessToken") as! String), forHTTPHeaderField: "accessToken")
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    Progress.hide(toView: self.view)
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        print(dict)
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
                        if dict.value(forKey: "wasOK") as! NSNumber == 1 {
                            Alert.show("Jane", message: "O email foi enviado com sucesso.", onVC: self)
                        } else {
                            Alert.show("Jane", message: "Por favor insira o endereço de e-mail válido", onVC: self)
                        }
                        Progress.hide(toView: self.view)
                    } catch _ {
                        Progress.hide(toView: self.view)
                    }

                } catch _ {
                    Progress.hide(toView: self.view)
                }
    
                }.resume()
        } else {
            Progress.hide(toView: self.view)
            Alert.internetConnectionError()
        }
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
