//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var rememberEmailSwitch:UISwitch!
    
    //MARK: -Properties
    private let storage = UserDefaults.standard
    private let emailKey = "email-Key"
    
    //MARK: -Actions
    @IBAction func loginBtnAction(){
        view.endEditing(true)
        performLogin()
    }
    

    //MARK: -App's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        //verificamos si en los UserDefaults hay algún dato
        if let storedEmail = storage.string(forKey: emailKey){
            //si hay algún dato almacenado, entonces lo asignamos al campo de texto
            emailTextField.text = storedEmail
            //mantenemos encendido el interruptor
            rememberEmailSwitch.isOn = true
        }else{
            //si no hay datos, entonces el switch se muestra desactivado
            rememberEmailSwitch.isOn = false
        }
    }
    
    
    //MARK: - Métodos privados
    private func setupUI(){
        //en este método se realizarán las modificaciones que se quieran realizar a la pantalla
        
        //para hacer el boton redondo
        loginButton.layer.cornerRadius = 25
        emailTextField.layer.cornerRadius = 25
        passwordTextField.layer.cornerRadius = 25
    }
    
    private func performLogin(){
        guard let email = emailTextField.text,
                          !email.isEmpty,
                          email.contains("@") else {
            NotificationBanner(title: "Error",
                               subtitle: "Email inválido",
                               style: .warning).show()
            
            return
        }
        
        guard let password = passwordTextField.text,
                             !password.isEmpty else {
            NotificationBanner(title: "Error",
                               subtitle: "Ingresa tu contraseña",
                               style: .warning).show()
            return
        }
        
        
        //Primer debemos realizar el request
        let request = LoginRequest(email: email, password: password)
        
        //Iniciamos la carga
        SVProgressHUD.show()
        
        //Llamada a la libreria de red
        SN.post(endpoint: EndPoints.login,
                model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //detenemos la carga
            SVProgressHUD.dismiss()
            
            //debemos manejar los cases que hay para SNResultWithEntity
            switch response{
            case .success(let user):
                //Se pudo realizar el login
                //NotificationBanner(subtitle: "Bienvenido \(user.user.names)",
                  //                 style: .success).show()
                self.performSegue(withIdentifier: "showHome", sender: nil)
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
                //en caso de que el usario desee que recordemos su correo se implementan los UserDefaults
                
                if self.rememberEmailSwitch.isOn{
                    self.storage.set(email, forKey: self.emailKey)
                }else{
                    self.storage.removeObject(forKey: self.emailKey)
                }
                
                DispatchQueue.main.async {
                    FloatingNotificationBanner(title: "Sesión Iniciada",
                                               subtitle: "Bienvenido \(user.user.names)",
                                               style: .success).show()
                }
                
            case .error(_):
                //se produce un error, no se puede manejar su componente
                NotificationBanner(title: "Error",
                                   subtitle: "Hubo un problema al intentar validarte",
                                   style: .danger).show()
            case .errorResult(let entity):
                //el error es manejable y devuelve una respuesta
                NotificationBanner(title: "Error",
                                   subtitle: "\(entity.error)",
                                   style: .danger).show()
            }
        }
        
    }

}
